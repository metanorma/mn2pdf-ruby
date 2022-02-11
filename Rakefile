require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require_relative 'lib/mn2pdf/version'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'open-uri'

def jar_url(ver)
  "https://github.com/metanorma/mn2pdf/releases/download/v#{ver}/mn2pdf-#{ver}.jar"
end

file 'bin/mn2pdf.jar' do |file|
  if Mn2pdf::VERSION != Mn2pdf::MN2PDF_JAR_VERSION
    begin
      open(jar_url(Mn2pdf::VERSION))
      abort(%(MN2PDF_JAR_VERSION in lib/mn2pdf/version.rb is outdated!
              Assign VERSION to MN2PDF_JAR_VERSION))
    rescue OpenURI::HTTPError => e
      # expected
    end
  end
  ver = Mn2pdf::MN2PDF_JAR_VERSION
  url = jar_url(Mn2pdf::MN2PDF_JAR_VERSION)
  File.open(file.name, 'wb') do |file|
    file.write open(url).read
  end
end