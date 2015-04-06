require 'helper'
require 'class_including_expect_behaviors'

class TestExpectBehaviors < Test::Unit::TestCase

  context "match registry" do
    setup do
      @includer = ClassIncludingExpectBehaviors.new
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
      @includer = ClassIncludingExpectBehaviors.new(wait: 2)
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

end
