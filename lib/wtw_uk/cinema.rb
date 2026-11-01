module WtwUk
  # The object representing a cinema on the WTW Cinemas website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the venue's TapOS site code, e.g. 'PLATRU'

    # Each venue is a subsite, and its programme request names it by Jacro
    # cinema id. Neither page names the TapOS site code its booking pages
    # use, and no page gives coordinates, so the gem holds the venues: names,
    # subsites and cinema ids from the quick booking menu, codes from booking
    # pages, addresses from venue page footers and coordinates from
    # OpenStreetMap.
    VENUES = {
      'WTWNEW' => {
        name: 'Newquay', path: 'newquay', location: '5', street_address: 'King Street', locality: 'Newquay',
        region: 'Cornwall', postal_code: 'TR7 1AA', latitude: 50.4136279, longitude: -5.0873384
      },
      'FILAUS' => {
        name: 'St Austell', path: 'st-austell', location: '1', street_address: 'White River Place',
        locality: 'St Austell', region: 'Cornwall', postal_code: 'PL25 5AZ', latitude: 50.3376527,
        longitude: -4.7948318
      },
      'PLATRU' => {
        name: 'Truro', path: 'truro', location: '2', street_address: '69 Lemon Street', locality: 'Truro',
        region: 'Cornwall', postal_code: 'TR1 2PN', latitude: 50.261851, longitude: -5.0523149
      },
      'REGWAD' => {
        name: 'Wadebridge', path: 'wadebridge', location: '3', street_address: 'The Platt', locality: 'Wadebridge',
        region: 'Cornwall', postal_code: 'PL27 7AD', latitude: 50.5152411, longitude: -4.8361756
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze
    WEBSITE = 'https://wtwcinemas.co.uk'.freeze

    # Constructor
    # @param [String] id the venue's TapOS site code, e.g. 'PLATRU' or 'platru'
    # @return [WtwUk::Cinema]
    def initialize(id)
      @id = id.to_s.upcase
    end

    # Return basic cinema information for all cinemas
    # @return [Array<WtwUk::Cinema>]
    # @example
    #   WtwUk::Cinema.all
    #   #=> [<WtwUk::Cinema>, <WtwUk::Cinema>, ...]
    def self.all
      VENUES.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = WtwUk::Cinema.new('PLATRU')
    #   cinema.adr
    #   #=> {
    #         street_address:   '69 Lemon Street',
    #         extended_address: nil,
    #         locality:         'Truro',
    #         region:           'Cornwall',
    #         postal_code:      'TR1 2PN',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, venue[part]] }.merge(country_name: 'United Kingdom')
    end

    # Brand of the cinema
    # @return [String] which will always be 'WTW Cinemas'
    def brand
      'WTW Cinemas'.freeze
    end

    # @return [Float, nil]
    def latitude
      venue[:latitude]
    end

    # Jacro's cinema id for the venue
    # @return [String, nil]
    # @api private
    def location
      venue[:location]
    end

    # @return [Float, nil]
    def longitude
      venue[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   WtwUk::Cinema.new('FILAUS').name
    #   #=> 'St Austell'
    def name
      venue[:name].to_s
    end

    # The venue's subsite on the WTW Cinemas website
    # @return [String, nil]
    # @api private
    def path
      venue[:path]
    end

    # The url of the cinema's pages on the WTW Cinemas website
    # @return [String]
    # @example
    #   WtwUk::Cinema.new('PLATRU').url
    #   #=> 'https://wtwcinemas.co.uk/truro/'
    def url
      path ? "#{WEBSITE}/#{path}/" : ''
    end

    private

    def venue
      VENUES.fetch(id, {})
    end
  end
end
