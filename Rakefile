require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "open-uri"
require_relative "lib/mn2pdf/version"

RSpec::Core::RakeTask.new(:spec)

task default: ["bin/mn2pdf.jar", :spec]

def jar_url(ver)
  "https://github.com/metanorma/mn2pdf/releases/download/v#{ver}/mn2pdf-#{ver}.jar"
end

file "bin/mn2pdf.jar" do |file|
  if Mn2pdf::VERSION != Mn2pdf::MN2PDF_JAR_VERSION
    begin
      URI.parse(jar_url(Mn2pdf::VERSION)).open
      abort(%(MN2PDF_JAR_VERSION in lib/mn2pdf/version.rb is outdated!
              Assign VERSION to MN2PDF_JAR_VERSION))
    rescue OpenURI::HTTPError, Errno::ENOENT
      # expected
    end
  end
  url = jar_url(Mn2pdf::MN2PDF_JAR_VERSION)
  print "Downloading #{url}..."
  File.binwrite(file.name, URI.parse(url).read)
end
