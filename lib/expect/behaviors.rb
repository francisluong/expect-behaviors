require 'pry'
require 'expect/match'
require 'expect/timeout_error'

module Expect

  ##
  # Add Expect behaviors to Accessor classes that have an input buffer: e.g. telnet/ssh
  # :Required methods to be created by the class mixing Expect::Behaviors :
  #   #exp_buffer - provide the current buffer contents and empty it
  #   #exp_process - should do one iteration of handle input and append buffer
  module Behavior

    EXP_TIMEOUT_SEC_DEFAULT = 10
    #initialize
    @exp_match_registry = {}
    @exp_match = nil
    @exp_timeout_sec = EXP_TIMEOUT_SEC_DEFAULT
    @exp_timeout_block = nil
    @exp_buffer = ''

    def expect(&block)
      #pre-action
      initialize_expect
      @exp_match_registry = {}
      #register callbacks
      instance_eval(&block)
      #action
      execute_expect_loop
      #post-action
    end

    def exp_timeout_sec=(timeout_sec)
      @exp_timeout_sec = timeout_sec
    end


    ##################
    private
    ##################

    def exp_registered_matches
      match_object = nil
      @exp_buffer ||= ''
      @exp_match_registry.each_pair do |expr, block|
        expr = expr.to_s unless expr.is_a?(Regexp)
        if @exp_buffer.match(expr)
          @exp_match = true
          match_object = Expect::Match.new(expression, @exp_buffer)
          block.call
        end
      end
      @exp_match = match_object
      @exp_match
    end

    def clear_expect_buffer
      @exp_buffer = ''
    end

    def execute_expect_loop
      begin
        Timeout::timeout(@exp_timeout_sec) do
          @exp_match = nil
          while exp_registered_matches.nil? do
            raise unless respond_to?(:exp_buffer)
            @exp_buffer << exp_process
          end
        end
      rescue Timeout::Error => e
        @exp_timeout_block.nil? ? timeout_action_default : @exp_timeout_block.call
      end
      @exp_match
    end

    def initialize_expect
      @exp_match_registry     = {}
      @exp_match              = nil
      @exp_timeout_sec        = EXP_TIMEOUT_SEC_DEFAULT
      @exp_timeout_block      = nil
      @exp_buffer           ||= ''
    end

    def timeout_action_default
      raise(TimeoutError)
    end

    def when_matching(expression, &block)
      @exp_match_registry[expression] = block
    end

    def when_timeout(timeout_sec = EXP_TIMEOUT_SEC_DEFAULT, &block)
      @exp_timeout_sec = timeout_sec
      @exp_timeout_block = block
    end


  end
end