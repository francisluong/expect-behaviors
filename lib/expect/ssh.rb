require 'net/ssh'
require 'logger'
require 'timeout'

require 'expect/behavior'

module Expect
  class SSH
    include Expect::Behavior

    attr_reader :auth_methods

    def initialize(hostname, username, port: 22, password: nil, ignore_known_hosts: false, key_file: nil, logout_command: "exit")
      @hostname = hostname
      @username = username
      @port = port
      @password = password
      @ignore_known_hosts = ignore_known_hosts
      @key_file = key_file
      @logout_command = logout_command
      @auth_methods = ['none', 'publickey', 'password']
      @ssh = nil
      @logger = Logger.new($stdout)
      @receive_buffer = ''
    end

    def start
      $stdout.puts(
          "[Expect::SSH##{__method__}] [@hostname=#{@hostname}] [@username=#{@username}] [options=#{options}]"
      )
      @ssh = Net::SSH.start(@hostname, @username, options)
      raise(RuntimeError, "[Expect::SSH##{__method__}]: SSH Start Failed") unless @ssh
      @channel = request_channel_pty_shell
      @channel.send_data("date\n")
      @ssh.process(0) {false}
    end


    def stop
      @logger.debug("[Expect::SSH##{__method__}]: Closing Channel")
      @channel.send_data(@logout_command + "\n")
      @channel.close
      begin
        Timeout::timeout(1) do
          @logger.debug("[Expect::SSH##{__method__}]: Closing Session")
          @ssh.close
        end
      rescue Timeout::Error
        @logger.debug("[Expect::SSH##{__method__}]: FORCE Closing Session")
        @ssh.shutdown!
      end
    end

    ################
    private
    ################

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

    def options
      override_options = {
          :auth_methods => auth_methods,
          :keys => [@key_file],
          :logger => @logger,
          :port => @port,
      }
      if @ignore_known_hosts
        override_options[:user_known_hosts_file] = '/dev/null'
      end
      Net::SSH.configuration_for(@host).merge(override_options)
    end

  end

end