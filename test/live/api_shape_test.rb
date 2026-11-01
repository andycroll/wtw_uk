require_relative 'live_helper'

# Every venue's programme and one booking page each, plus the home page:
# nine requests.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  VENUE_LINK = %r{href="/([a-z-]+)/whats-on/"}
  LOCATION = %r{<option value="(\d+)">WTW ([^<]+?)\s*</option>}
  TAPOS_CODE = %r{/sales/([A-Z]+)/book\?perfcode=}

  def test_programmes_are_readable
    WtwUk::Cinema.all.each do |cinema|
      html = WtwUk::Internal::Website.new.programme(cinema.path, cinema.location)
      assert_programme_shape(html, cinema.path)
      assert_booking_page_names_the_venue(cinema, html)
    end
  end

  def test_home_page_lists_the_venues_the_gem_holds
    html = fetch('https://wtwcinemas.co.uk/')

    assert_equal WtwUk::Cinema.all.map(&:path).sort, html.scan(VENUE_LINK).flatten.uniq.sort
    locations = html.scan(LOCATION).to_h { |location, name| [name, location] }
    WtwUk::Cinema.all.each { |cinema| assert_equal cinema.location, locations[cinema.name], cinema.id }
  end

  private

  def assert_booking_page_names_the_venue(cinema, html)
    booking_url = WtwUk::Internal::Parser::Programme.new(html).showtimes.filter_map { |s| s.to_hash[:booking_url] }.first
    assert_equal cinema.id, fetch(booking_url)[TAPOS_CODE, 1]
  end

  def fetch(url)
    response = Net::HTTP.get_response(URI(url))
    assert_kind_of Net::HTTPSuccess, response, url
    response.body.force_encoding(Encoding::UTF_8)
  end
end
