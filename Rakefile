require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "open-uri"
require "yaml"
require_relative "lib/mn2pdf/version"

RSpec::Core::RakeTask.new(:spec)

task default: ["bin/mn2pdf.jar", :spec]

def jar_url(ver)
  "https://github.com/metanorma/mn2pdf/releases/download/v#{ver}/mn2pdf-#{ver}.jar"
end

def jar_exists?(ver)
  uri = URI.parse(jar_url(ver))
  begin
    uri.open
    true
  rescue OpenURI::HTTPError, Errno::ENOENT
    false
  end
end

file "bin/mn2pdf.jar" do |file|
  if Mn2pdf::VERSION != Mn2pdf::MN2PDF_JAR_VERSION
    # VERSION differs from MN2PDF_JAR_VERSION - validate VERSION JAR exists
    # (this is the patch-release scenario where only Ruby version changes)
    unless jar_exists?(Mn2pdf::VERSION)
      abort(%(MN2PDF_JAR_VERSION in lib/mn2pdf/version.rb is outdated!
              VERSION #{Mn2pdf::VERSION} JAR not found, but MN2PDF_JAR_VERSION #{Mn2pdf::MN2PDF_JAR_VERSION} exists.
              Update version.rb: set MN2PDF_JAR_VERSION to the existing Java version.))
    end
  end
  url = jar_url(Mn2pdf::MN2PDF_JAR_VERSION)
  puts "Downloading #{url}..."
  File.binwrite(file.name, URI.parse(url).read)
end

namespace :release do
  desc "Validate that JAR exists for the given version"
  task :validate_jar, [:version] do |_, args|
    version = args[:version]
    if jar_exists?(version)
      puts "JAR exists for v#{version}"
      exit 0
    else
      puts "JAR does NOT exist for v#{version}"
      exit 1
    end
  end

  desc "Bump version for release"
  task :bump, [:version] do |_, args|
    version = args[:version]
    raise "Usage: rake release:bump[version]" unless version

    version_file = "lib/mn2pdf/version.rb"
    content = File.read(version_file)

    current_version = Mn2pdf::VERSION
    current_jar_version = Mn2pdf::MN2PDF_JAR_VERSION

    if jar_exists?(version)
      # JAR exists for this version - proper release, update both
      puts "JAR v#{version} exists: updating both VERSION and MN2PDF_JAR_VERSION"
      content.gsub!(/VERSION = "[^"]+"/, "VERSION = \"#{version}\"")
      # Handle both MN2PDF_JAR_VERSION = "x.y.z" and MN2PDF_JAR_VERSION = VERSION
      content.gsub!(/MN2PDF_JAR_VERSION = "[^"]+"/, "MN2PDF_JAR_VERSION = \"#{version}\"")
      content.gsub!(/MN2PDF_JAR_VERSION = VERSION/, "MN2PDF_JAR_VERSION = \"#{version}\"")
    else
      # JAR does not exist - patch release (Ruby-only changes)
      # Only update VERSION, keep MN2PDF_JAR_VERSION at existing JAR version
      jar_version = current_jar_version
      # If MN2PDF_JAR_VERSION was referencing VERSION constant, resolve it
      if jar_version == current_version
        # Infer base version: 2.50.1 -> 2.50, 2.51.3 -> 2.51
        base_version = version.split('.')[0...-1].join('.')
        if jar_exists?(base_version)
          jar_version = base_version
          puts "Inferred JAR version #{jar_version} from #{version}"
        else
          abort("Cannot determine JAR version for patch release #{version}. Please set MN2PDF_JAR_VERSION manually.")
        end
      end

      puts "JAR v#{version} does NOT exist: patch release, updating only VERSION (MN2PDF_JAR_VERSION stays at #{jar_version})"
      content.gsub!(/VERSION = "[^"]+"/, "VERSION = \"#{version}\"")
      content.gsub!(/MN2PDF_JAR_VERSION = "[^"]+"/, "MN2PDF_JAR_VERSION = \"#{jar_version}\"")
      content.gsub!(/MN2PDF_JAR_VERSION = VERSION/, "MN2PDF_JAR_VERSION = \"#{jar_version}\"")
    end

    File.write(version_file, content)
    puts "Updated #{version_file}:"
    puts content
  end
end
