require 'expect/behaviors'
class ClassIncludingExpectBehaviors
  include Expect::Behavior

  attr_reader :exp_buffer

  def initialize(wait: nil, values: {})
    @exp_buffer = nil
    @exp_buffer_values = values
    @wait_sec = wait
  end

  def exp_process
    sleep(@wait_sec.to_i)
    @exp_buffer = @exp_buffer_values.shift
    @exp_buffer.to_s
  end

end