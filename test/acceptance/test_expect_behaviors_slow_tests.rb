require 'helper'
require 'expect/behavior'
require 'class_including_expect_behavior'
gem 'mocha'
require 'mocha/test_unit'

class TestExpectBehaviorsSlowTests < Test::Unit::TestCase

  ####################################
  context "expect" do
    setup do
      @values = []
      @values << "the sun is a mass"
      @values << "\nof incandescent gas"
      @values << "\nswitch-prompt#"
      @values << "\nblip blip"
      @values << "\nblah blah"
      @values << "\nswitch-prompt2#"
      @includer = ClassIncludingExpectBehavior.new(values: @values)
      @wait_sec = 0.5
    end

    should "not timeout for switch-prompt2# if expect_continue for blip" do
      @includer.wait_sec = @wait_sec * 1
      result = @includer.expect do
        when_matching(/switch-prompt2#/) do
          @exp_match
        end
        when_matching(/blip/) do
          exp_continue
        end
        when_timeout(@wait_sec * 4) do
          "timed out"
        end
      end
      expected = "the sun is a mass\nof incandescent gas\nswitch-prompt#\nblip blip\nblah blah\nswitch-prompt2#"
      assert_equal(expected, result.to_s)
    end

    should "timeout for switch-prompt2# if expect_continue for incandescent" do
      @includer.wait_sec = @wait_sec * 1
      result = @includer.expect do
        when_matching(/switch-prompt2#/) do
          @exp_match
        end
        when_matching(/incandescent/) do
          exp_continue
        end
        when_timeout(@wait_sec * 3) do
          "timed out"
        end
      end
      expected = "timed out"
      assert_equal(expected, result.to_s)
    end

  end


  ####################################
  context "timeout" do
    setup do
      @wait_sec = 0.5
      @includer = ClassIncludingExpectBehavior.new(wait: @wait_sec * 2)
    end

    should "raise TimeoutError when timeout is reached before match is found" do
      @includer.exp_timeout_sec = 1
      assert_raises(Expect::TimeoutError) do
        @includer.expect do
          when_matching(/bob/) do
            return_value
          end
        end
      end
    end

    should "execute arbitrary block on timeout with override" do
      result = @includer.expect do
        when_matching(/bob/) do
          return_value
        end
        when_timeout(@wait_sec * 1) do
          "timeout"
        end
      end
      assert_equal('timeout', result)
    end
  end

end
