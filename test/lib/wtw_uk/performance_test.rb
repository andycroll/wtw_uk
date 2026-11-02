require_relative '../../test_helper'

class WtwUk::PerformanceTest < Minitest::Test
  include WebsiteStubs

  DATE = Date.new(2026, 12, 16)
  BOOKING = 'https://wtwcinemas.co.uk/truro/booknow/'.freeze

  def setup
    stub_programme
  end

  def test_at_returns_performances_in_time_order
    performances = performances_at('PLATRU')

    assert(performances.all? { |p| p.instance_of?(WtwUk::Performance) })
    assert_equal 45, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_every_date_from_one_request
    performances_at('platru')

    assert_requested :post, TRURO, times: 1
  end

  def test_at_keeps_to_the_range
    assert_equal 5, WtwUk::Performance.at('PLATRU', from: DATE, to: DATE).count
  end

  def test_at_defaults_to_a_fortnight_from_today_in_london
    Cinebase::London.stub(:today, Date.new(2026, 11, 2)) do
      assert_equal 12, WtwUk::Performance.at('PLATRU').count
    end
  end

  def test_at_sets_cinema_details
    performances = performances_at('PLATRU')

    assert_equal ['PLATRU'], performances.map(&:cinema_id).uniq
    assert_equal ['Truro'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at('PLATRU').first

    assert_equal 'Primetime', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 11, 1, 16, 45), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_empty performance.variant
    assert_nil performance.festival
    assert_nil performance.booking_url
  end

  def test_booking_links_skip_the_redirect
    performance = performances_at('PLATRU').detect { |p| p.starting_at == Time.utc(2026, 12, 16, 10, 30) }

    assert_equal 'Avengers: Doomsday', performance.film_name
    assert_equal "#{BOOKING}122756/", performance.booking_url
  end

  def test_summer_times_are_converted_to_utc
    performance = performances_at('PLATRU').last

    assert_equal 'Royal Ballet and Opera: Romeo And Juliet', performance.film_name
    assert_equal Time.utc(2027, 5, 25, 18, 15), performance.starting_at
    assert_equal %w(arts), performance.variant
  end

  def test_silver_screen_subtitled_screenings
    performance = find('122882')

    assert_equal 'Heart of the Beast', performance.film_name
    assert_equal %w(senior subtitled), performance.variant
    assert performance.subtitled?
  end

  def test_autism_friendly_screenings_are_relaxed
    performance = find('122883')

    assert_equal 'Ultimate Thunder', performance.film_name
    assert_equal %w(relaxed subtitled), performance.variant
  end

  def test_event_cinema_is_arts
    assert_equal %w(arts), find('121994').variant
  end

  def test_event_cinema_without_its_class_is_arts
    performance = find('120565')

    assert_equal 'Exhibition on Screen: Renoir & Love', performance.film_name
    assert_equal %w(arts), performance.variant
  end

  def test_q_and_a_screenings
    performance = find('122968')

    assert_equal '82: The Ben Nevis Log Challenge (Mandown)', performance.film_name
    assert_equal %w(q&a), performance.variant
  end

  def test_previews_and_film_club_strands_keep_the_film_title
    assert_equal 'Dune: Part Three', find('122453').film_name
    performance = performances_at('PLATRU').detect { |p| p.starting_at == Time.utc(2026, 11, 1, 18) }
    assert_equal "Rosemary's Baby & The Babadook Double Bill", performance.film_name
  end

  def test_unknown_cinema_makes_no_request
    assert_empty WtwUk::Performance.at('WTWZZZ', from: DATE, to: DATE)
    assert_not_requested :post, /wtwcinemas/
  end

  def test_to_must_not_precede_from
    assert_raises(ArgumentError) { WtwUk::Performance.at('PLATRU', from: DATE, to: DATE - 1) }
  end

  private

  def performances_at(cinema_id)
    WtwUk::Performance.at(cinema_id, from: Date.new(2026, 11, 1), to: Date.new(2027, 11, 1))
  end

  def find(booking_id)
    performances_at('PLATRU').detect { |p| p.booking_url&.end_with?("/#{booking_id}/") }
  end
end
