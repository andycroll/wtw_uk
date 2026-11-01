# frozen_string_literal: true

module WtwUk
  # @api private
  module Internal
    module Parser
      # Reads a venue's whole programme: a block for each film, with its
      # showtimes in order under date headings such as
      # '<strong>Wednesday </strong>16 December 2026'
      class Programme
        FILM = '<div class="poster-case '
        TITLE = %r{<span class="poster-title">([^<]*)</span>}
        DATE = %r{dateshow"><strong>[^<]*</strong>\s*(\d{1,2} [A-Z][a-z]+ \d{4})\s*</span>}
        SHOWTIME = %r{<div class="singlefilmperfs ([^"]*)">(.*?)<input type="hidden" class="perfcat_message"}m

        # @param [String] html a venue's programme
        def initialize(html)
          @html = html
        end

        # @return [Array<WtwUk::Internal::Parser::Showtime>] every showtime,
        #   including those already passed today
        def showtimes
          @html.split(FILM).drop(1).flat_map do |markup|
            title = markup[TITLE, 1]
            title ? film_showtimes(CGI.unescapeHTML(title), markup) : []
          end
        end

        private

        def film_showtimes(title, markup)
          date = nil
          markup.scan(/#{DATE}|#{SHOWTIME}/o).filter_map do |day, classes, perf|
            if day
              date = Date.strptime(day, '%d %B %Y')
              nil
            elsif date
              Showtime.new(perf, title: title, date: date, classes: classes)
            end
          end
        end
      end
    end
  end
end
