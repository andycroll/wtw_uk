require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_programme_fixture_matches_shape
    assert_programme_shape(JSON.parse(programme_json('truro')).fetch('html'), 'truro')
  end
end
