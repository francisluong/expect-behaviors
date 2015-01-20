require 'helper'
require 'expect/match'

class TestExpectMatch < Test::Unit::TestCase
  context "default" do
    should "return full buffer by calling #buffer method" do
      match = Expect::Match.new(expr1, buffer1)
      assert(buffer1, match.buffer)
    end

    should "return matching buffer text when calling #exact_match_string" do
      match = Expect::Match.new(expr1, buffer1)
      assert_equal(expr1.source, match.exact_match_string)
    end

    should "return the part of the buffer up to the first matching text when calling #substring_up_to_match" do
      match = Expect::Match.new(expr1, buffer1)
      assert_equal("testing\nbob", match.substring_up_to_match)
    end

    should "return the part of the buffer following the first matching text when calling #substring_remainder" do
      match = Expect::Match.new(expr1, buffer1)
      assert_equal(" is cool\nbob is good", match.substring_remainder)
    end
  end

  def expr1
    /bob/
  end

  def buffer1
    "testing\nbob is cool\nbob is good"
  end
end
