# frozen_string_literal: true

module WtwUk
  # @api private
  module Internal
    module Parser
      # Parses one showtime from a venue's programme into performance
      # attributes
      class Showtime
        # Showtime classes and the variants they mean. Others, such as
        # 'audio-des' and 'ccap' (headsets and caption glasses on offer),
        # 'sub-titles' (also on every opera), 'laser', 'strobe-lgt' and
        # 'percatediscountedscreening' (cheap tickets), are not variants.
        CLASSES = {
          'aslive' => 'arts',
          'aut' => 'relaxed',
          'percateeventcinemascreening' => 'arts',
          'sil' => 'senior',
          'subtitled' => 'subtitled'
        }.freeze

        # Event cinema classes are missing from some showtimes
        TITLE_VARIANTS = {
          /\b(?:Exhibition On Screen|National Theatre Live|NT Live|Royal Ballet (?:&|and) Opera|Live On Stage)\b/i =>
            'arts',
          /\s-\sThe Play\z/i => 'arts',
          /\bQ&A\b/i => 'q&a',
          /\bsubtitle[ds]\b/i => 'subtitled'
        }.freeze

        THREE_D_CLASS = 'icon-3d'
        THREE_D = /\b3D\b/i
        START = %r{Start time:<span>(\d{1,2}):(\d{2})</span>}
        BOOKING = %r{href="(https://wtwcinemas\.co\.uk/[a-z-]+/booknow/\d+)/?"}
        # Venues differ over hyphens and en dashes in the same title
        EN_DASH = ' – '
        LANGUAGE = /\((#{Cinebase::TitleSanitizer::LANGUAGES.join('|')})\)/i

        # @return [Date] the local date of the showtime
        attr_reader :date

        # @param [String] markup the showtime's markup
        # @param [String] title the film's title as listed
        # @param [Date] date from the showtime's date heading
        # @param [String] classes the showtime's class attribute
        def initialize(markup, title:, date:, classes:)
          @markup = markup
          @title = title.gsub(EN_DASH, ' - ').strip
          @date = date
          @classes = classes.downcase.split
        end

        # @return [Hash] options for WtwUk::Performance.new
        def to_hash
          {
            booking_url: booking_url,
            dimension: @classes.include?(THREE_D_CLASS) || @title.match?(THREE_D) ? '3d' : '2d',
            festival: Cinebase::Festival.from_title(@title, year: @date.year),
            film_name: TitleSanitizer.new(@title).sanitized,
            film_year: Cinebase::TitleSanitizer.film_year(@title),
            language: @title[LANGUAGE, 1],
            starting_at: starting_at,
            variant: variant
          }
        end

        private

        # Showtimes already passed have no link
        def booking_url
          url = @markup[BOOKING, 1]
          url && "#{url}/"
        end

        def starting_at
          hour, minute = @markup.match(START).captures.map(&:to_i)
          local = Time.utc(@date.year, @date.month, @date.day, hour, minute)
          Cinebase::London.utc(local)
        end

        def variant
          from_title = TITLE_VARIANTS.filter_map { |pattern, variant| variant if @title.match?(pattern) }
          (@classes.filter_map { |name| CLASSES[name] } + from_title).uniq
        end
      end
    end
  end
end
