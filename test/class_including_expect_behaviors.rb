require 'expect/behaviors'
class ClassIncludingExpectBehaviors
  include Expect::Behavior

  attr_accessor :expect_buffer

  def initialize
    @exp_buffer = nil
  end

  def exp_process

  end

  def exp_buffer

  end
end