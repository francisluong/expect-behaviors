require 'rake/testtask'


namespace :test do

  test_libs = {
    :default => ['lib', 'test']
  }

  test_suites = [:unit, :acceptance]

  task :all do
    test_suites.each do |suite_sym|
      test_name = "test:#{suite_sym}"
      Rake::Task[test_name].invoke
    end
  end

  test_suites.each do |subtest_sym|
    Rake::TestTask.new(subtest_sym) do |test|
      libs = test_libs[subtest_sym]
      libs ||= test_libs[:default]
      test.libs +=  libs
      test.pattern = "test/#{subtest_sym.to_s}/**/test_*.rb"
      test.verbose = true
    end
  end

end

desc "Run All Tests"
task :test => 'test:all'
