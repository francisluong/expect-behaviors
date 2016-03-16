# expect-behaviors
Ruby Mixin to add Expect Behaviors to SSH/Serial/Telnet controllers

[![Build Status](https://travis-ci.org/francisluong/expect-behaviors.svg?branch=master)](https://travis-ci.org/francisluong/expect-behaviors)
[![Code Climate](https://codeclimate.com/github/francisluong/expect-behaviors/badges/gpa.svg)](https://codeclimate.com/github/francisluong/expect-behaviors)
[![Test Coverage](https://codeclimate.com/github/francisluong/expect-behaviors/badges/coverage.svg)](https://codeclimate.com/github/francisluong/expect-behaviors)

# Using the Mixin

Two public methods are required to support adding expect behaviors to your controller. 
 
-   #exp_process - should do one iteration of handle input and append buffer
-   #exp_buffer - provide the current buffer contents from controller and empty it

# An Example: Expect::SSH

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

# That's All the Crummy Documentation?

For now, yes.  I need to learn how to use YARD and RDOC.  Sorry!

-Franco
