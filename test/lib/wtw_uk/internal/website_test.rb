require_relative '../../../test_helper'

class WtwUk::Internal::WebsiteTest < Minitest::Test
  include WebsiteStubs

  def test_programme_reads_a_venue_programme
    stub_programme

    html = WtwUk::Internal::Website.new.programme('truro', '2')

    assert_includes html, 'Avengers: Doomsday'
  end

  def test_missing_html_is_empty
    stub_request(:post, TRURO).to_return(status: 200, body: '{}')

    assert_equal '', WtwUk::Internal::Website.new.programme('truro', '2')
  end

  def test_errors_name_the_status_but_not_the_body
    stub_request(:post, TRURO).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { WtwUk::Internal::Website.new.programme('truro', '2') }
    assert_equal 'WTW Cinemas HTTP error 500', error.message
  end

  def test_redirects_are_not_followed
    stub_request(:post, TRURO).to_return(status: 301, headers: { 'Location' => 'https://wtwcinemas.co.uk/' })

    assert_raises(RuntimeError) { WtwUk::Internal::Website.new.programme('truro', '2') }
  end

  def test_transient_errors_are_retried
    stub_request(:post, TRURO).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: programme_json('truro'))
    website = WtwUk::Internal::Website.new

    website.stub(:sleep, nil) { website.programme('truro', '2') }

    assert_requested :post, TRURO, times: 2
  end

  def test_retries_give_up
    stub_request(:post, TRURO).to_raise(Net::OpenTimeout)
    website = WtwUk::Internal::Website.new

    assert_raises(Net::OpenTimeout) { website.stub(:sleep, nil) { website.programme('truro', '2') } }
    assert_requested :post, TRURO, times: 3
  end
end
