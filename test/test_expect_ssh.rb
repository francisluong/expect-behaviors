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

  context :init_and_start do

    setup do
      @ssh = Expect::SSH.new(@@hostname, @@username, port: @@port, key_file: @@sshd.client_key_path, ignore_known_hosts: true)
    end

    teardown do
      @@sshd.teardown
    end

    should "return an options hash when calling #options" do
      expected = {
          :auth_methods=>["none", "pubkey", "password"],
          :keys=>[@@sshd.client_key_path],
          :port=>[@@port],
          :user_known_hosts_file=>"/dev/null"
      }
      assert_equal(expected, @ssh.send(:options))
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
