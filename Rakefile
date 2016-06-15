require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new :test do |test|
  test.libs << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = ENV.has_key?("VERBOSE")
end

task default: :test
