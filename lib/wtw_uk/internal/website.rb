# frozen_string_literal: true

module WtwUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads WTW's WordPress website, built on Jacro's cinema plugin, with a
    # subsite for each venue. No token is needed.
    class Website
      include Http

      HOME = 'https://wtwcinemas.co.uk'
      # The what's on page's request when a date is chosen
      ACTION = 'jacro_filter_result'
      # The 'All Shows' date, which lists every showtime on sale
      ALL_DATES = 'moredates'
      FILM_TYPE = 'Now Showing'

      # @param [String] path the venue's subsite, e.g. 'truro'
      # @param [String] location Jacro's cinema id for the venue, e.g. '2'
      # @return [String] every film the venue has on sale, each with every
      #   showtime under date headings, however far ahead
      def programme(path, location)
        form = { 'action' => ACTION, 'film_date' => ALL_DATES, 'film_type' => FILM_TYPE, 'cinema_id' => location }
        JSON.parse(post("#{HOME}/#{path}/wp-admin/admin-ajax.php", form)).fetch('html', '').to_s
      end
    end
  end
end
