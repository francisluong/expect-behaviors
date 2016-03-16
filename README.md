# expect-behaviors
Ruby Mixin to add Expect Behaviors to SSH/Serial/Telnet controllers

[![Build Status](https://travis-ci.org/francisluong/expect-behaviors.svg?branch=master)](https://travis-ci.org/francisluong/expect-behaviors)
[![Code Climate](https://codeclimate.com/github/francisluong/expect-behaviors/badges/gpa.svg)](https://codeclimate.com/github/francisluong/expect-behaviors)
[![Test Coverage](https://codeclimate.com/github/francisluong/expect-behaviors/badges/coverage.svg)](https://codeclimate.com/github/francisluong/expect-behaviors)

# Using the Mixin

Two public methods are required to support adding expect behaviors to your controller. 
 
-   #exp_process - should do one iteration of handle input and append buffer
-   #exp_buffer - provide the current buffer contents from controller and empty it

The you need to include the module in your class:

```ruby
require 'expect/behavior'

class Klass
    include Expect::Behavior
end

```

# Batteries Included: Expect::SSH

You can find an example which uses the module in this repo: [Expect::SSH](lib/expect/ssh.rb).  This example implements the required methods:

```ruby
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
```

# Using Expect

Once Expect::Behaviors has been included you should be able to use Expect blocks in your code.  

Here is an example assuming an instance of Expect::SSH that expects a switch prompt and includes a timeout block that expires after 3 seconds.  It returns different values depending on how things work out.

```ruby
result = @ssh.expect do
    when_matching(/switch-prompt1#/) do
      "switch 1"
    end
    when_matching(/switch-prompt2#/) do
      "switch 2"
    end
    when_timeout(3) do
      "timed out"
    end
end
```

You can set the timeout value:

```ruby
@ssh.exp_timeout_sec = 2 * 60
```

You can set the exp_sleep_interval_sec between buffer checks:

```ruby
@includer.exp_sleep_interval_sec = 10
```

# Expect::Match

And you can use #exp_match or return @exp_match from within a #when_matching block to return an Expect::Match object.

Expect::Match exposes the following methods:

 - #buffer - returns the full contents of the buffer that matched
 - #exact_match_string - returns the first capture from the match
 - #to_s - returns the contents of the buffer up to the match
 - #remainder - returns the contents of the buffer following the first match
 - #nil? - true if there were no matches 

# That's All the Crummy Documentation?

For now, yes.  I need to learn how to use YARD and RDOC.  Sorry!

-Franco
