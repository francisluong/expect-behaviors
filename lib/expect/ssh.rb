require 'net/ssh'
require 'logger'
require 'timeout'

require 'expect/behavior'

module Expect

  ##
  # An SSH Accessor with expect-like behaviors.  See also Expect::Behavior.
  class SSH
    include Expect::Behavior
    # :Required methods to be created by the class mixing Expect::Behaviors :
    #   #exp_process - should do one iteration of handle input and append buffer
    #   #exp_buffer - provide the current buffer contents and empty it

    attr_reader :auth_methods

    def initialize(hostname, username,
                   # keyword args follow
                   port: 22,
                   password: nil, # password for login
                   ignore_known_hosts: false, # ignore host key mismatches?
                   key_file: nil, # path to private key file
                   logout_command: "exit", # command to exit/logout SSH session on remote host
                   wait_interval_sec: 0.1) # process interval
      @hostname = hostname
      @username = username
      @port = port
      @password = password
      @ignore_known_hosts = ignore_known_hosts
      @key_file = key_file
      @logout_command = logout_command
      @wait_interval_sec = wait_interval_sec
      @auth_methods = ['none', 'publickey', 'password']
      @ssh = nil
      @logger = Logger.new($stdout)
      @receive_buffer = ''
    end

    ##
    # Transmit the contents of +command+ using the SSH @channel
    def send_data(command)
      @logger.debug("[Expect::SSH##{__method__}] [@hostname=#{@hostname}] [command=#{command}]")
      command += "\n" unless command.end_with?("\n")
      @channel.send_data(command)
    end

    ##
    # Initiate SSH connection
    def start
      $stdout.puts(
          "[Expect::SSH##{__method__}] [@hostname=#{@hostname}] [@username=#{@username}] [options=#{options}]"
      )
      @ssh = Net::SSH.start(@hostname, @username, options)
      raise(RuntimeError, "[Expect::SSH##{__method__}]: SSH Start Failed") unless @ssh
      @channel = request_channel_pty_shell
    end

    ##
    # Close SSH connection
    def stop
      @logger.debug("[Expect::SSH##{__method__}]: Closing Channel")
      @channel.send_data(@logout_command + "\n")
      @channel.close
      begin
        # A net-ssh quirk is that if you send a graceful close but you don't send an exit, it'll hang forever
        # ...see also: http://stackoverflow.com/questions/25576454/ruby-net-ssh-script-not-closing
        # I send an exit but just in case, also force the shutdown if it doesn't happen in 1 second.  #NotPatient
        Timeout::timeout(1) do
          @logger.debug("[Expect::SSH##{__method__}]: Closing Session")
          @ssh.close
        end
      rescue Timeout::Error
        @logger.debug("[Expect::SSH##{__method__}]: FORCE Closing Session")
        @ssh.shutdown!
      end
    end

    ##
    # exp_buffer - provide the current buffer contents and empty it
    def exp_buffer
      result = @receive_buffer
      @receive_buffer = ''
      result
    end

    ##
    # exp_process - should do one iteration of handle input and append buffer
    def exp_process
      sleep(@wait_sec.to_f)
      @ssh.process(0)
    end

    ################
    private
    ################

    ##
    # Sets up the channel, pty, and shell.
    # Configures callbacks for handling incoming data.
    def request_channel_pty_shell
      channel = @ssh.open_channel do |channel|
        @logger.debug("[Expect::SSH##{__method__}]: Requesting PTY")
        channel.request_pty do |_ch, success|
          raise(RuntimeError, "[Expect::SSH##{__method__}]: Unable to get PTY") unless success
        end
        @logger.debug("[Expect::SSH##{__method__}]: Requesting Shell")
        channel.send_channel_request("shell") do |_ch, success|
          raise(RuntimeError, "[Expect::SSH##{__method__}]: Unable to get SHELL") unless success
        end
        @logger.debug("[Expect::SSH##{__method__}]: Registering Callbacks")
        channel.on_data do |_ch, data|
          @logger.debug("[Expect::SSH] [on_data=#{data}]")
          @receive_buffer << data
          false
        end
        channel.on_extended_data do |_ch, type, data|
          @logger.debug("[Expect::SSH] [on_extended_data=#{data}]")
          @receive_buffer << data if type == 1
          false
        end
        channel.on_close do
          @logger.debug("[Expect::SSH]: Close Channel")
        end
      end
      @logger.debug("[Expect::SSH##{__method__}] complete")
      channel
    end

    ##
    # Construct the options hash to feed Net::SSH
    def options
      override_options = {
          :auth_methods => auth_methods,
          :keys => [@key_file],
          :logger => @logger,
          :port => @port,
      }
      override_options[:user_known_hosts_file] = '/dev/null' if @ignore_known_hosts
      override_options[:password] = @password if @password
      Net::SSH.configuration_for(@host).merge(override_options)
    end

  end

end