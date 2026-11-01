require_relative '../../test_helper'

class WtwUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil WtwUk::VERSION
  end
end
