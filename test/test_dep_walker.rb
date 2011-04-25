require "test/unit"
require "dep_walker"

class TestDepWalker < Test::Unit::TestCase
  def test_no_argument
    deps = DepWalker.dependencies
    assert deps.is_a? Array
    assert_equal 0, deps.length
  end

  def test_dep_walker
    path = File.join(File.expand_path('../../lib/dep_walker', __FILE__), 'dep_walker.so')
    deps = DepWalker.dependencies path
    assert_equal 4, deps.length
    assert deps.include? 'msvcrt.dll'
    assert deps.include? 'imagehlp.dll'
  end
end
