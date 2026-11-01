module WtwUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [WtwUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\ASee It First\s+-\s+/i,                                     # preview
          /\s*-\s*Pat's [^-]+\z/,                                       # Truro's film club strands
          /\s+(?:-\s+)?(?:Subtitled and )?Autism Friendly Screening\z/i, # relaxed screening
          /\s+(?:inc\.?|plus)\s+(?:[\w-]+\s+)*Q&A\z/i                   # Q&A add-on
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\A(.*) - Royal Ballet (?:&|and) Opera \d{2}-\d{2} Season\z/i => 'Royal Ballet and Opera: ',
          /\A(.*) - Exhibition On Screen\z/i                             => 'Exhibition on Screen: ',
          /\ANT Live: (.*)/                                              => 'National Theatre Live: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
