require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = ARGV[1..-1]
end

Rake::TestTask.new('test:all') do |t|
  t.test_files = Dir.glob('test/**/*_test.rb')
end
