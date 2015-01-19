require 'helper'
require 'expect/match'

class TestExpectMatch < Test::Unit::TestCase
  context "placeholder" do
    should "be able to get full buffer by calling #buffer method" do
      expr = /bob/
      buffer = "testing\nbob is cool"
      match = Expect::Match.new(expr, buffer)
      assert(buffer, match.buffer)
    end
  end
end
