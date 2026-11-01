require_relative 'fixtures_helper'

# Serve the fixture in place of the WTW Cinemas website
module WebsiteStubs
  include FixturesHelper

  TRURO = 'https://wtwcinemas.co.uk/truro/wp-admin/admin-ajax.php'.freeze
  PROGRAMME = {
    'action' => 'jacro_filter_result', 'film_date' => 'moredates', 'film_type' => 'Now Showing', 'cinema_id' => '2'
  }.freeze

  private

  def stub_programme
    stub_request(:post, TRURO).with(body: PROGRAMME).to_return(status: 200, body: programme_json('truro'))
  end
end
