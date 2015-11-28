require 'erb'
require 'fileutils'
require 'socket'


##
# A Helper to start a second instance of SSHD on an unprivilege port which allows for a custom client key
#  All keys for this server are created just in time.
class SSHD

  TEST_ROOT = File.dirname(__FILE__)
  SSHD_CFG_ROOT = File.join(TEST_ROOT, 'acceptance', 'sshd')
  SSHD_TMP_ROOT = File.join(TEST_ROOT, 'tmp', 'sshd')
  PIDFILE_PATH = File.join(SSHD_TMP_ROOT, 'sshd.pid')
  ERB_ROOT = File.join(SSHD_CFG_ROOT, 'erb')
  CONFIG_ERB_PATH = File.join(ERB_ROOT, 'sshd_config.erb')
  SSHD_CONFIG_PATH = File.join(SSHD_TMP_ROOT, 'sshd_config')
  SSHD_LOG_PATH = File.join(SSHD_TMP_ROOT, 'sshd.log')

  KEY_ROOT = SSHD_TMP_ROOT
  SSHD_CLIENT_KEY_PATH = File.join(KEY_ROOT, 'id_rsa')
  SSHD_CLIENT_PUBKEY_PATH = File.join(KEY_ROOT, 'id_rsa.pub')
  SSHD_RSA_HOST_KEY_PATH = File.join(KEY_ROOT, 'ssh_host_key_rsa')
  SSHD_DSA_HOST_KEY_PATH = File.join(KEY_ROOT, 'ssh_host_key_dsa')
  SSHD_AUTHORIZED_KEYS_PATH = SSHD_CLIENT_PUBKEY_PATH

  def initialize(address = '127.0.0.1')
    @tcpserver = nil
    @address = address
    @port = reserve_unprivileged_tcp_port
    @sshd_filepath = %x(which sshd).chomp
    @ssh_keygen_filepath = %x(which ssh-keygen).chomp
    teardown
  end

  def start
    unless openssh_files_found?
      raise(RuntimeError, "[SSHD] Error: Unable to locate sshd or ssh-keygen.")
    end
    create_config
    generate_keys
    release_port
    start_ssh_server
  end

  def stop
    this_pid = pid
    unless this_pid.nil?
      $stdout.puts("[SSHD] [#{__method__}]: Killing SSHD, [pid=#{this_pid}]")
      begin
        Process.kill(0, this_pid)
      rescue Errno::ESRCH
        $stderr.puts("[SSHD] [#{__method__}]: No Action: Process not found, [pid=#{this_pid}]")
      ensure
        File.delete(PIDFILE_PATH) if File.exists?(PIDFILE_PATH)
      end
    else
      $stderr.puts("[SSHD] [#{__method__}]: No Action: PIDFILE Doesnt exist: #{PIDFILE_PATH}")
    end
  end

  def teardown
    stop
    clean_tmp_root
  end


  #####################
  private
  #####################

  def clean_tmp_root
    FileUtils.rmtree(SSHD_TMP_ROOT)
    FileUtils.mkpath(SSHD_TMP_ROOT)
    nil
  end

  def create_config
    erb = ERB.new(IO.read(CONFIG_ERB_PATH))
    result = erb.result(binding)
    File.open(SSHD_CONFIG_PATH, 'w') {|f| f.write(result)}
    result
  end

  def generate_keys
    [SSHD_CLIENT_KEY_PATH, SSHD_RSA_HOST_KEY_PATH, SSHD_DSA_HOST_KEY_PATH].each do |key_path|
      %x(#{@ssh_keygen_filepath} -t rsa -b 4096 -C user@localhost -f #{key_path} -N '')
    end
  end

  def openssh_files_found?
    not @ssh_keygen_filepath.empty? and not @sshd_filepath.empty?
  end

  def pid
    pid = nil
    if File.exists?(PIDFILE_PATH)
      pid = IO.read(PIDFILE_PATH).chomp.to_i
    end
    pid
  end

  def reserve_unprivileged_tcp_port
    @tcpserver ||= TCPServer.new(@host, 0)
    @port = @tcpserver.addr[1]
  end

  def release_port
    @tcpserver.close
    @tcpserver = nil
    @port
  end

  def start_ssh_server
    %x(#{@sshd_filepath} -4 -f #{SSHD_CONFIG_PATH} -E #{SSHD_LOG_PATH})
    $stdout.puts("[SSHD] [#{__method__}]: Starting on [port=#{@port}]")
    sleep(3)
    $stdout.puts("[SSHD] [#{__method__}]: Started on [port=#{@port}] [pid=#{pid}]")
    pid
  end
end

