# frozen_string_literal: true

require 'net/http'

module WtwUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Requests to wtwcinemas.co.uk
    module Http
      RETRIES = 2
      TRANSIENT_ERRORS = [
        EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError
      ].freeze

      private

      def post(url, form)
        uri = URI(url)
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(form)
        attempts = 0
        begin
          response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
            http.request(request)
          end
        rescue *TRANSIENT_ERRORS
          attempts += 1
          raise if attempts > RETRIES

          sleep(attempts)
          retry
        end
        # Omit response bodies from errors, and never follow redirects.
        raise "WTW Cinemas HTTP error #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        String.new(response.body, encoding: Encoding::UTF_8)
      end
    end
  end
end
