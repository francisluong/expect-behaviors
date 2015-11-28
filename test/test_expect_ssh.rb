require 'helper'
require 'sshd'

require 'expect/ssh'

class TestExpectSSH < Test::Unit::TestCase

  def self.startup
    @@hostname = '127.0.0.1'
    @@username = ENV['USER']
    @@sshd = SSHD.new
    @@sshd.start
    @@port = @@sshd.port
  end


  def self.shutdown
    @@sshd.teardown
  end

  context :init_and_start do

    setup do
      @ssh = Expect::SSH.new(@@hostname, @@username, port: @@port, key_file: @@sshd.client_key_path, ignore_known_hosts: true)
    end

    should "return an options hash when calling #options" do
      expected = {
          :auth_methods => ["none", "publickey", "password"],
          :keys => [@@sshd.client_key_path],
          :logger => nil,
          :port => @@port,
          :user_known_hosts_file => "/dev/null"
      }
      result = @ssh.send(:options)
      result[:logger] = nil
      assert_equal(expected, result)
    end
  end

  context :startup do

    setup do
      @ssh = Expect::SSH.new(@@hostname, @@username, port: @@port, key_file: @@sshd.client_key_path, ignore_known_hosts: true)
    end

    should "be able to authenticate" do
      @ssh.start
      @ssh.stop
    end

  end

end
