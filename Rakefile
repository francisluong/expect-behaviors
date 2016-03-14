# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'rake'
require 'rake/clean'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

task :default => :test

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |raketask| load raketask }

CLEAN.include("*.gem")
