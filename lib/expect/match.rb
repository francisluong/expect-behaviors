module Expect
  class Match
    attr_reader :buffer
    def initialize(expression, buffer)
      @expression = expression
      @buffer = buffer
    end
  end
end