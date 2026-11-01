require_relative 'live_helper'

class LiveIntegrationTest < Minitest::Test
  def test_every_cinema_has_performances
    today = Date.today

    WtwUk::Cinema.all.each do |cinema|
      performances = WtwUk::Performance.at(cinema.id, from: today, to: today + 365)

      assert(performances.all? { |p| p.instance_of?(WtwUk::Performance) })
      assert_operator performances.count, :>, 10, cinema.id
      assert_operator performances.map(&:showing_on).max, :>, today + 14, cinema.id
      assert(performances.all? { |p| p.booking_url.nil? || p.booking_url.match?(ApiShapes::BOOKING_URL) }, cinema.id)
    end
  end
end
