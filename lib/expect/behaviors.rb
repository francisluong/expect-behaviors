require 'pry'
require 'expect/match'

module Expect

  ##
  # Add Expect behaviors to Accessor classes that have an input buffer: e.g. telnet/ssh
  # :Required methods to be created by the class mixing Expect::Behaviors :
  #   #exp_buffer - provide the current buffer contents and empty it
  #   #exp_process - should do one iteration of handle input and append buffer
  module Behavior

    EXP_TIMEOUT_SEC_DEFAULT = 10
    #initialize
    @exp_match_registry     = {}
    @exp_match              = nil
    @exp_timeout_sec        = EXP_TIMEOUT_SEC_DEFAULT
    @exp_timeout_block      = nil
    @exp_buffer      = nil

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


    ##################
    private
    ##################

    def check_match(expression, buffer)
      match_object = nil
      if expression =~ buffer
        @exp_match       = true
        match_object = Expect::Match.new(expression, buffer)
        block.call(match_object)
      end
      match_object
    end

    def clear_expect_buffer
      @exp_buffer = nil
    end

    def execute_expect_loop
      begin
        Timeout::timeout(@exp_timeout_sec) do
          @exp_match = nil
          while match.nil? do
            process
            @exp_buffer ||= ""
            @exp_buffer << send(exp_expect_buffer_method)
            @exp_match_registry.each_pair do |expression, block|
              match_object = check_match(expression, buffer)
            end
          end
        end
      rescue Timeout::Error => e
        @exp_timeout_block.nil? ? timeout_action_default : @exp_timeout_block.call
      end
    end

    def initialize_expect
      @exp_match_registry     = {}
      @exp_match              = nil
      @exp_timeout_sec        = EXP_TIMEOUT_SEC_DEFAULT
      @exp_timeout_block      = nil
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

    # Error Classes
    class TimeoutError < StandardError
    end
  end
end