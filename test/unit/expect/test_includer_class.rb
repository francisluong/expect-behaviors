require 'helper'
require 'class_including_expect_behavior'

class TestIncluderClass < Test::Unit::TestCase
  context "includer class" do
    setup do
      @includer = ClassIncludingExpectBehavior.new
    end

    should "have a method #exp_buffer which returns the current contents of the input buffer" do
      assert(@includer.respond_to?(:exp_buffer))
    end

    should "have a method #process which processes session input for some amount of time and updates the input
buffer" do
      assert(@includer.respond_to?(:exp_process))
    end

    should "set @wait_sec when initialized with kwarg: 'wait'" do
      assert_equal(10, ClassIncludingExpectBehavior.new(wait: 10).instance_variable_get(:@wait_sec))
    end

    should "return empty string for exp_process by default" do
      assert_equal('', @includer.exp_process)
    end

    should "return buffer values in sequence when init with kwarg: 'values'" do
      includer = ClassIncludingExpectBehavior.new(values: ["one", "TWO"])
      assert_equal("one", includer.exp_process)
      assert_equal("oneTWO", includer.exp_process)
    end

  end
end
