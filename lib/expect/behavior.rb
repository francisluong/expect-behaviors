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
    attr_accessor :exp_sleep_interval_sec

    EXP_TIMEOUT_SEC_DEFAULT = 10
    EXP_SLEEP_INTERVAL_SEC_DEFAULT = 0.1

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

    def current_time
      Time.now.to_f
    end

    def exp_registered_matches
      match_object = nil
      unless @__exp_buffer.nil?
        @exp_match_registry.each_pair do |expr, block|
          expr = expr.to_s unless expr.is_a?(Regexp)
          if @__exp_buffer.match(expr)
            result = block.call
            match_object = result.eql?('exp_continue') ? nil : Expect::Match.new(expr, @__exp_full_buffer)
            break # don't try to match more than one
          end
        end
      end
      @exp_match = match_object
      @exp_match
    end

    ##
    # reset timeout and continue expect loop
    def expect_continue
      init_timeout
      @__exp_buffer = '' # avoid matching the same text twice
      "exp_continue"
    end
    alias_method :exp_continue, :expect_continue
    alias_method :reset_timeout, :expect_continue

    def execute_expect_loop
      init_timeout
      @exp_match = nil
      result = nil
      @__exp_buffer = ''
      @__exp_full_buffer = ''
      while result.nil?
        if timeout?
          result = @exp_timeout_block.nil? ? timeout_action_default : @exp_timeout_block.call
        else
          raise unless respond_to?(:exp_buffer)
          raise unless respond_to?(:exp_process)
          # call process/buffer and then check for match
          exp_process
          newbuffertext = exp_buffer.to_s
          @__exp_buffer << newbuffertext
          @__exp_full_buffer << newbuffertext
          if exp_registered_matches
            result = @exp_match
          else
            sleep(@exp_sleep_interval_sec)
          end
        end
      end
      result
    end

    def initialize_expect
      @exp_match_registry ||= {}
      @exp_match = nil
      @exp_sleep_interval_sec ||= EXP_SLEEP_INTERVAL_SEC_DEFAULT
      @exp_timeout_sec ||= EXP_TIMEOUT_SEC_DEFAULT
      @exp_timeout_block ||= nil
      @__exp_buffer ||= ''
      @__exp_full_buffer ||= ''
    end

    def init_timeout
      @start_time = current_time
    end

    def timeout?
      (current_time - @start_time) > @exp_timeout_sec
    end

    def timeout_action_default
      raise(TimeoutError, "Expect Timeout [start_time=#{@start_time}] [time=#{current_time}]")
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