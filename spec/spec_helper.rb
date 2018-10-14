require "bundler/setup"

require 'simplecov'
SimpleCov.start do
  add_filter "lib/symbolize.rb"
  add_filter "spec"
end

require "pry"
require "fileutils"
require "time"

SUPPORT_ROOT = File.expand_path('support/', __dir__)
PROJECT_ROOT = File.expand_path('../', __dir__)

module SpecHelper
  
  def support_path(*filenames)
    File.join SUPPORT_ROOT, filenames
  end
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.default_formatter = "doc" if config.files_to_run.one?
  
  config.include SpecHelper
    
  config.before(:each) do
    entries = Dir.entries support_path 'mp3s'
    entries.select! {|e| !e.end_with? '.mp3'}.map! {|e| support_path('mp3s', e)}
    FileUtils.rm_f entries
  end
  
  config.order = :random
  Kernel.srand config.seed
  
  config.before(:suite) do
    mtimes = YAML.load_file File.join(SUPPORT_ROOT, 'mtimes.yml')
    
    mtimes.each {|f, t| FileUtils.touch(File.join(SUPPORT_ROOT, f), mtime: Time.parse(t))}
  end
  
end
