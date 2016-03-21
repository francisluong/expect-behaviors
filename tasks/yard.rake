namespace :yard do
  @pid = nil
  desc "Start YARD server for this gem"
  task :start do
    output = `yard server --gems -d`
    @pid = $?.pid
    $stdout.puts("YARD Server Started: [#{output.rstrip}] [pid=#{@pid}]")
  end

  desc "Stop YARD Server"
  task :stop do
    pidline = `ps -e | grep yard | egrep -v "(grep|rake)"`.chomp
    if pidline.empty?
      $stdout.puts("No YARD Server to Kill")
    else
      pid = pidline.split(" ").first.to_i
      Process.kill(9, pid)
      $stdout.puts("YARD Server Killed: [pid=#{pid}] [pidline=#{pidline}]")
    end
  end

  desc "Connecto to YARD Server"
  task :open do
    uri = "http://localhost:8808"
    `open #{uri}`
    $stdout.puts("Opening in Browser: [uri=#{uri}]")
  end
end
