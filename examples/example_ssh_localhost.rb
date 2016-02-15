require 'expect/ssh'

hostname = 'localhost'
@ssh = Expect::SSH.new(hostname, ENV['USER'], ignore_known_hosts: true)
@ssh.start
prompt = /.*\$/
@ssh.expect { when_matching(prompt) { @exp_match } } # first prompt

def strip_command_and_prompt(expect_match)
  expect_match.buffer.lines[1..-2].join.strip
end

@ssh.send_data('date')
result = @ssh.expect do
  when_matching(prompt) {@exp_match}
end
date = strip_command_and_prompt(result)

@ssh.send_data('uname -a')
result = @ssh.expect do
  when_matching(prompt) {@exp_match}
end
uname = strip_command_and_prompt(result)

puts "[date=#{date}]"
puts "[uname=#{uname}]"

print "[TEST timeout action: "
@ssh.send_data('sleep 3')
result = @ssh.expect do
  when_matching(prompt) {"FAILED - got prompt"}
  when_timeout(1)       {"PASSED"}
end
puts result + ']'

@ssh.stop
