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

  context :expect do

    setup do
      @ssh = Expect::SSH.new(@@hostname, @@username, port: @@port, key_file: @@sshd.client_key_path, ignore_known_hosts: true)
      @ssh.start
    end

    teardown do
      @ssh.stop
    end

    should "be able to send a few commands" do
      result = @ssh.expect do
        when_matching(/.*\$.*/) { @exp_match }
      end
      assert_match(/Last login:/, result.to_s)
      @ssh.send_data("cat /etc/resolv.conf")
      result = @ssh.expect do
        when_matching(/.*nameserver.*/) { @exp_match }
      end
      assert_match(/nameserver [\d\.]+.*/, result.exact_match_string)
      @ssh.send_data("date")
      result = @ssh.expect do
        when_matching(/.*20.*/) { @exp_match }
      end
      assert_match(/20/, result.exact_match_string)
    end

    should "timeout as expected" do
      result = @ssh.expect do
        when_matching(/.*\$.*/) { @exp_match }
      end
      assert_match(/Last login:/, result.to_s)
      @ssh.send_data("sleep 2")
      result = @ssh.expect do
        when_matching(/.*\$.*/) { @exp_match }
        when_timeout(1) { "timeout" }
      end
      assert_match(/timeout/, result)
    end

  end

end
