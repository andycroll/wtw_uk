require 'cgi/escape'
require 'json'

require 'cinebase'

require_relative './wtw_uk/version'

require_relative './wtw_uk/internal/http'
require_relative './wtw_uk/internal/website'
require_relative './wtw_uk/internal/title_sanitizer'
require_relative './wtw_uk/internal/parser/showtime'
require_relative './wtw_uk/internal/parser/programme'

require_relative './wtw_uk/cinema'
require_relative './wtw_uk/performance'

# wtw_uk gem
module WtwUk
end
