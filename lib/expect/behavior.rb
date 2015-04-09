require 'pry'
require 'expect/match'
require 'expect/timeout_error'

module Expect

  ##
  # Add Expect behaviors to Accessor classes that have an input buffer: e.g. telnet/ssh
  # :Required methods to be created by the class mixing Expect::Behaviors :
  #   #exp_process - should do one iteration of handle input and append buffer
  #   #exp_buffer - provide the current buffer contents and empty it
module Behavior

    attr_reader :exp_match
    attr_accessor :exp_timeout_sec

    EXP_TIMEOUT_SEC_DEFAULT = 10
    def expect(&block)
      #pre-action
      initialize_expect if @__exp_buffer.nil?
      @exp_match_registry = {}
      #register callbacks
      instance_eval(&block)
      #action
      execute_expect_loop
      #post-action
    end


    ##################
    private
    ##################

    def clear_expect_buffer
      @__exp_buffer = ''
    end

    def exp_registered_matches
      match_object = nil
      unless @__exp_buffer.nil?
        @exp_match_registry.each_pair do |expr, block|
          expr = expr.to_s unless expr.is_a?(Regexp)
          if @__exp_buffer.match(expr)
            match_object = Expect::Match.new(expr, @__exp_buffer)
            block.call
          end
        end
      end
      @exp_match = match_object
      @exp_match
    end

    def execute_expect_loop
      begin
        Timeout::timeout(@exp_timeout_sec) do
          @exp_match = nil
          while exp_registered_matches.nil? do
            raise unless respond_to?(:exp_buffer)
            raise unless respond_to?(:exp_process)
            exp_process
            @__exp_buffer << exp_buffer.to_s
          end
        end
        @exp_match
      rescue Timeout::Error => e
        @exp_timeout_block.nil? ? timeout_action_default : @exp_timeout_block.call
      end
    end

    def initialize_expect
      @exp_match_registry ||= {}
      @exp_match = nil
      @exp_timeout_sec ||= EXP_TIMEOUT_SEC_DEFAULT
      @exp_timeout_block ||= nil
      @__exp_buffer ||= ''
    end

    def timeout_action_default
      raise(TimeoutError)
    end

    def when_matching(expression, &block)
      @exp_match_registry[expression] = block
    end
    alias_method :when_match, :when_matching

    def when_timeout(timeout_sec = nil, &block)
      @exp_timeout_sec = timeout_sec unless timeout_sec.nil?
      @exp_timeout_block = block
    end


  end
end