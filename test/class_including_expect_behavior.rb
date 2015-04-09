require 'expect/behavior'

class ClassIncludingExpectBehavior
  include Expect::Behavior
  #   #exp_buffer - provide the current buffer contents and empty it
  #   #exp_process - should do one iteration of handle input and append buffer

  attr_accessor :exp_buffer_values, :wait_sec

  def initialize(wait: nil, values: [])
    @exp_buffer = ''
    @exp_buffer_values = values
    @wait_sec = wait
  end

  def exp_buffer
    result = @exp_buffer
    @exp_buffer = ''
    result
  end

  ##
  #   #exp_buffer - provide the current buffer contents and empty it
  def exp_process
    sleep(@wait_sec.to_i)
    # handle input
    @exp_buffer << @exp_buffer_values.shift.to_s
  end

end