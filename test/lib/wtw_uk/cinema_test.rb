require_relative '../../test_helper'

class WtwUk::CinemaTest < Minitest::Test
  IDS = %w(WTWNEW FILAUS PLATRU REGWAD).freeze

  def test_all_returns_every_venue_without_requests
    cinemas = WtwUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(WtwUk::Cinema) })
    assert_equal IDS, cinemas.map(&:id)
  end

  def test_new_stores_upcase_string_id
    assert_equal 'PLATRU', WtwUk::Cinema.new('platru').id
  end

  def test_name_full_name_and_slug
    cinema = WtwUk::Cinema.new('FILAUS')

    assert_equal 'St Austell', cinema.name
    assert_equal 'WTW Cinemas St Austell', cinema.full_name
    assert_equal 'wtw-cinemas-st-austell', cinema.slug
  end

  def test_brand
    assert_equal 'WTW Cinemas', WtwUk::Cinema.new('PLATRU').brand
  end

  def test_url
    assert_equal 'https://wtwcinemas.co.uk/st-austell/', WtwUk::Cinema.new('FILAUS').url
  end

  def test_adr
    expected = {
      street_address:   '69 Lemon Street',
      extended_address: nil,
      locality:         'Truro',
      region:           'Cornwall',
      postal_code:      'TR1 2PN',
      country_name:     'United Kingdom'
    }

    assert_equal expected, WtwUk::Cinema.new('PLATRU').adr
  end

  def test_coordinates
    cinema = WtwUk::Cinema.new('REGWAD')

    assert_in_delta 50.5152411, cinema.latitude
    assert_in_delta(-4.8361756, cinema.longitude)
  end

  def test_every_venue_has_a_postcode_coordinates_and_location
    WtwUk::Cinema.all.each do |cinema|
      refute_empty cinema.locality, cinema.id
      assert_match(/\A[A-Z]{2}\d{1,2} \d[A-Z]{2}\z/, cinema.postal_code, cinema.id)
      assert_kind_of Float, cinema.latitude, cinema.id
      assert_kind_of Float, cinema.longitude, cinema.id
      assert_match(/\A\d+\z/, cinema.location, cinema.id)
    end
  end

  def test_unknown_cinema_has_no_details
    cinema = WtwUk::Cinema.new('WTWZZZ')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    assert_nil cinema.latitude
  end
end
