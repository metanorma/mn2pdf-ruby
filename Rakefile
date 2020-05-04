require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require_relative 'lib/mn2pdf/version'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'open-uri'

file 'bin/mn2pdf.jar' do |file|
  ver = Mn2pdf::VERSION
  url = "https://github.com/metanorma/mn2pdf/releases/download/v#{ver}/mn2pdf-#{ver}.jar"
  File.open(file.name, 'wb') do |file|
    file.write open(url).read
  end
end