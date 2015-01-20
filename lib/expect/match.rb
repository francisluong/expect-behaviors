module Expect
  class Match
    attr_reader :buffer, :success

    def initialize(expression, buffer)
      @expression = expression
      @buffer     = buffer
      @matches    = @buffer.match(@expression)
    end

    def exact_match_string
      @matches.nil? ? nil : @matches[0]
    end

    def substring_up_to_match
      if @matches.nil?
        nil
      else
        new_expr = substring_expression
        @buffer.match(new_expr)[0]
      end
    end

    alias_method :to_s, :substring_up_to_match

    def substring_remainder
      start_index = substring_up_to_match.length
      @buffer[start_index..-1]
    end

    ###
    private

    def substring_expression
      Regexp.new(".*?#{@expression.source}", @expression.options | Regexp::MULTILINE)
    end

  end
end