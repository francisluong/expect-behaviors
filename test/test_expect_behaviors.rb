require 'helper'
require 'class_including_expect_behaviors'

class TestExpectBehaviors < Test::Unit::TestCase
  context "includer" do
    setup do
      @includer = ClassIncludingExpectBehaviors.new
    end

    should "have a method #exp_buffer which returns the current contents of the input buffer" do
      assert(@includer.respond_to?(:exp_buffer))
    end

    should "have a method #process which processes session input for some amount of time and updates the input
buffer" do
      assert(@includer.respond_to?(:exp_process))
    end
  end

  context "expect" do
    setup do
      @includer = ClassIncludingExpectBehaviors.new
    end

    should "populate the match registry" do
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
end
