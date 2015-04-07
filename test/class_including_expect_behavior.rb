require 'expect/behavior'

class ClassIncludingExpectBehavior
  include Expect::Behavior

  attr_reader :exp_buffer
  attr_accessor :exp_buffer_values, :wait_sec

  def initialize(wait: nil, values: [])
    @exp_buffer = ''
    @exp_buffer_values = values
    @wait_sec = wait
  end

  def exp_process
    sleep(@wait_sec.to_i)
    @exp_buffer << @exp_buffer_values.shift.to_s
    @exp_buffer.to_s
  end

end