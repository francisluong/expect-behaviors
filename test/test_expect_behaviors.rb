require 'helper'
require 'expect/behavior'
require 'class_including_expect_behavior'

class TestExpectBehaviors < Test::Unit::TestCase

  context "match registry" do
    setup do
      @includer = ClassIncludingExpectBehavior.new
    end

    should "be populated by when_matching statements" do
      @includer.stubs(:execute_expect_loop)
      return_value = "Matched BOB"
      @includer.expect do
        when_matching(/bob/) do
          return_value
        end
        when_matching(/joe/) do
          "Matched JOE"
        end
        when_timeout do
          "TIMEOUT"
        end
      end
      assert_equal(/bob/, @includer.instance_variable_get(:@exp_match_registry).keys.first)
      assert_equal(2, @includer.instance_variable_get(:@exp_match_registry).length)
      assert_equal(return_value, @includer.instance_variable_get(:@exp_match_registry).values.first.call)
      assert_equal("TIMEOUT", @includer.instance_variable_get(:@exp_timeout_block).call)
    end
  end

  context "timeout" do
    setup do
      @includer = ClassIncludingExpectBehavior.new(wait: 2)
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
        when_timeout(1) do
          "timeout"
        end
      end
      assert_equal('timeout', result)
    end
  end

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
    end

    should "match up to first switch-prompt" do
      result = @includer.expect do
        when_matching(/switch-prompt#/) do
          @exp_match
        end
      end
      expected = "the sun is a massthe sun is a mass\nof incandescent gasthe sun is a massthe sun is a mass\nof incandescent gas\nswitch-prompt#"
      assert_equal(expected, result.to_s)
    end

    should "timeout for switch-prompt2#" do
      @includer.wait_sec = 1
      @includer.exp_timeout_sec = 4
      result = @includer.expect do
        when_matching(/switch-prompt2#/) do
          @exp_match
        end
        when_timeout(3) do
          "timed out"
        end
      end
      assert_equal('timed out', result.to_s)
    end

  end

end
