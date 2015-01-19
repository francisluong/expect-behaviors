require 'pry'

module Expect
  module Behavior

    TIMEOUT_SEC_DEFAULT = 10
    #initialize
    @match_registry = {}
    @match = nil
    @timeout_sec = TIMEOUT_SEC_DEFAULT
    @timeout_block = nil

    def timeout_action_default
      raise(TimeoutError)
    end

    def exp_process_method
      :process
    end

    def exp_expect_buffer_method
      :expect_buffer
    end

    def do_expect(&block)
      #pre-action
      @match_registry = {}
      instance_eval(&block)
      execute_expect_loop
    end

    def execute_expect_loop
      begin
        Timeout::timeout(@timeout_sec) do
          @match = nil
          while match.nil? do
            send(exp_process)
            buffer = send(exp_expect_buffer_method)
            @match_registry.each_pair do |expression, block|
              match_object = check_match(expression, buffer)
            end
          end
        end
      rescue Timeout::Error => e
        @timeout_block.nil? ? timeout_action_default : @timeout_block.call
      end
    end
    private :execute_expect_loop

    def check_match(expression, buffer)
      match_object = nil
      if expression =~ buffer
        @match = true
        match_object = ::Expect::Match.new(expression, buffer)
        block.call(match_object)
      end
      match_object
    end
    private :check_match

    def when_matching(expression, &block)
      @match_registry[expression] = block
    end

    def when_timeout(timeout_sec, &block)
      @timeout_sec = timeout_sec
    end

    # Error Classes
    class TimeoutError < StandardError
    end
  end
end