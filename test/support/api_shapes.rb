# The parts of a venue's programme the gem reads. Checked against the
# trimmed fixture and, in the live suite, against real programmes held only
# in memory.
module ApiShapes
  BOOKING_URL = %r{\Ahttps://wtwcinemas\.co\.uk/[a-z-]+/booknow/\d+/\z}
  PARSER = WtwUk::Internal::Parser::Programme
  SHOWTIME = '<div class="singlefilmperfs '.freeze
  PASSED = 'past_performance'.freeze
  CLASS = /\A[a-z0-9-]+\z/

  private

  def assert_programme_shape(html, path)
    films = html.split(PARSER::FILM).drop(1)
    refute_empty films
    films.each { |film| assert_match PARSER::TITLE, film }
    showtimes = PARSER.new(html).showtimes
    assert_equal html.scan(SHOWTIME).size, showtimes.size
    assert_equal html.scan(PASSED).size, showtimes.count { |showtime| showtime.to_hash[:booking_url].nil? }
    showtimes.each { |showtime| assert_showtime_shape(showtime, path) }
    html.scan(PARSER::SHOWTIME).each do |classes, _markup|
      classes.split.each { |name| assert_match CLASS, name.downcase }
    end
  end

  def assert_showtime_shape(showtime, path)
    attributes = showtime.to_hash
    refute_empty attributes[:film_name]
    assert_kind_of Time, attributes[:starting_at]
    booking_url = attributes[:booking_url]
    assert(booking_url.nil? || (booking_url.match?(BOOKING_URL) && booking_url.include?("/#{path}/")), booking_url)
  end
end
