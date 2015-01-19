require 'helper'
require 'class_including_expect_behaviors'

class TestExpectBehaviors < Test::Unit::TestCase
  context "the class including expect/behaviors" do
    setup do
      @includer = ClassIncludingExpectBehaviors.new
    end

    should "have a method #expect_buffer which returns the current contents of the input buffer" do
      assert(@includer.respond_to?(:expect_buffer))
    end

    should "have a method #process which processes session input for some amount of time and updates the input
buffer" do
      assert(@includer.respond_to?(:process))
    end
  end
end
