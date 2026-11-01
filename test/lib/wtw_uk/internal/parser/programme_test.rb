require_relative '../../../../test_helper'

class WtwUk::Internal::Parser::ProgrammeTest < Minitest::Test
  include FixturesHelper

  SHOWTIME = '<div class="singlefilmperfs icon-2d "><div class="perfmods">' \
             '<li>Start time:<span>19:00</span></li></div><input type="hidden" class="perfcat_message" value="">'.freeze

  def test_showtimes_take_the_date_heading_above_them
    showtimes = parse(JSON.parse(programme_json('truro')).fetch('html'))
    avengers = showtimes.select { |showtime| showtime.to_hash[:film_name] == 'Avengers: Doomsday' }

    assert_equal 25, avengers.size
    assert_equal Date.new(2026, 12, 16), avengers.first.date
    assert_equal Date.new(2026, 12, 23), avengers.last.date
  end

  def test_titles_are_unescaped
    html = film('Rosemary&#039;s Baby', '<span class="firstdateshow"><strong>Today </strong>01 November 2026</span>')

    assert_equal "Rosemary's Baby", parse(html).first.to_hash[:film_name]
  end

  def test_blocks_without_a_title_are_skipped
    assert_empty parse('<div class="poster-case singlethree">no title</div>')
  end

  def test_showtimes_without_a_date_heading_are_skipped
    assert_empty parse(film('Verity', ''))
  end

  private

  def film(title, heading)
    %(<div class="poster-case singlethree"><span class="poster-title">#{title}</span>#{heading}#{SHOWTIME})
  end

  def parse(html)
    WtwUk::Internal::Parser::Programme.new(html).showtimes
  end
end
