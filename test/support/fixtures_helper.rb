# Read fixtures from disk: Truro's programme from 1 November 2026, trimmed
# to a few films with shortened descriptions. It follows the shape in
# api_shapes.rb.
module FixturesHelper
  private

  def programme_json(path)
    read_fixture("website/programme-#{path}.json")
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
