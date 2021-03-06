module Expect
  class Match
    attr_reader :buffer, :success

    def initialize(expression, buffer)
      @expression = expression
      @buffer     = buffer
      @matches    = @buffer.match(@expression)
    end

    # returns the first capture from the match
    def exact_match_string
      @matches.nil? ? nil : @matches[0]
    end

    def expr_substring_to_match
      Regexp.new(".*?#{@expression.source}", @expression.options | Regexp::MULTILINE)
    end

    # true if there were no matches
    def nil?
      @matches.nil?
    end

    # returns the contents of the buffer up to the match
    def substring_up_to_match
      @matches.nil? ? nil : @buffer.match(expr_substring_to_match)[0]
    end
    alias_method :to_s, :substring_up_to_match

    # returns the contents of the buffer following the first match
    def substring_remainder
      if @matches.nil?
        @buffer
      else
        start_index = substring_up_to_match.length
        @buffer[start_index..-1]
      end
    end
    alias_method :remainder, :substring_remainder

  end
end