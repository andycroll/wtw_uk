require_relative '../../../../test_helper'

class WtwUk::Internal::Parser::ShowtimeTest < Minitest::Test
  DATE = Date.new(2026, 11, 7)
  MARKUP = '<div class="hiddenbox-wrapper perfbtn 4 sh_6 " >19:00 ' \
           '<a class="hiddenbox-wrapper-link " href="https://wtwcinemas.co.uk/st-austell/booknow/79338" >' \
           '<ul class="hiddenbox-items"><li>Start time:<span>19:00</span></li></ul></a></div>'.freeze

  def test_en_dashes_read_as_hyphens
    assert_equal 'GIANT - The Play', parse('GIANT – The Play', 'percateEventCinemaScreening aslive')[:film_name]
    assert_equal 'Dune: Part Three', parse('See It First – Dune: Part Three')[:film_name]
  end

  def test_three_d
    assert_equal '3d', parse('Avengers: Doomsday', 'percateStandardScreening icon-3d')[:dimension]
    assert_equal '3d', parse('Avengers: Doomsday 3D')[:dimension]
  end

  def test_screen_formats_offers_and_access_are_not_variants
    classes = 'percateDiscountedScreening laser strobe-lgt audio-des ccap nomemtck sub-titles icon-2d'

    assert_empty parse('Verity', classes)[:variant]
  end

  def test_each_variant_once
    assert_equal %w(subtitled), parse('Wicker (with subtitles)', 'subtitled sub-titles')[:variant]
  end

  def test_language_festival_and_year_from_the_title
    assert_equal 'Hindi', parse('Ramayana: Rise of a Legend (Hindi)')[:language]
    assert_equal 'Cambridge Film Festival', parse('CFF: Paddington')[:festival].name
    assert_equal 1971, parse('The Devils (1971)')[:film_year]
  end

  def test_performances_read_audience_labels_from_the_title
    hash = parse('Relaxed Screening: Wicker')
    performance = WtwUk::Performance.new(hash.merge(cinema_id: 'PLASTA', cinema_name: 'St Austell'))

    assert_equal 'Wicker', performance.film_name
    assert_equal %w(relaxed), performance.variant
  end

  def test_booking_url_and_date
    showtime = WtwUk::Internal::Parser::Showtime.new(MARKUP, title: 'Verity', date: DATE, classes: '')

    assert_equal DATE, showtime.date
    assert_equal 'https://wtwcinemas.co.uk/st-austell/booknow/79338/', showtime.to_hash[:booking_url]
    assert_equal Time.utc(2026, 11, 7, 19), showtime.to_hash[:starting_at]
  end

  private

  def parse(title, classes = 'percateStandardScreening icon-2d')
    WtwUk::Internal::Parser::Showtime.new(MARKUP, title: title, date: DATE, classes: classes).to_hash
  end
end
