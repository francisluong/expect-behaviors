require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rubygems'
require 'bundler'
gem 'mocha'
require 'mocha/test_unit'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

# add lib folder from parent
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# ...and the test folder
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'expect/behavior'