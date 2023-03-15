require "open3"
require "rbconfig"
require "tempfile"
require "yaml"

module Mn2pdf
  MN2PDF_JAR_PATH = File.join(File.dirname(__FILE__), "../bin/mn2pdf.jar")
  DEFAULT_JAVA_OPTS = %w[-Xss5m -Xmx2048m -Djava.awt.headless=true].freeze
  FONTS_MANIFEST = :font_manifest

  def self.jvm_options
    options = DEFAULT_JAVA_OPTS.dup

    if RbConfig::CONFIG["host_os"].match?(/darwin|mac os/)
      options << "-Dapple.awt.UIElement=true"
    end

    options << "-Duser.home=#{Dir.home}"

    options
  end

  def self.help
    cmd = ["java", *jvm_options, "-jar", MN2PDF_JAR_PATH].join(" ")
    # help message goes to STDERR (from mn2pdf v1.36)
    _, help_message, = Open3.capture3(cmd)
    help_message
  end

  def self.version
    cmd = ["java", *jvm_options, "-jar", MN2PDF_JAR_PATH, "-v"].join(" ")
    message, = Open3.capture3(cmd)
    message.strip
  end

  def self.convert(url_path, output_path, xsl_stylesheet, options = {})
    cmd = build_cmd(url_path, output_path, xsl_stylesheet)

    return unless cmd

    case options
    when String
      mn2pdf(cmd + [options])
    when Hash
      mn2pdf_hash(cmd, options)
    else
      warn "Unsupported options type #{options.class}"
    end
  end

  def self.build_cmd(url, output, xslt)
    return if url.nil? || output.nil? || xslt.nil?

    ["java", *jvm_options,
     "-jar", MN2PDF_JAR_PATH,
     "--xml-file", quote(url),
     "--xsl-file", quote(xslt),
     "--pdf-file", quote(output)]
  end

  def self.mn2pdf_hash(cmd, options)
    manifest = options.delete(FONTS_MANIFEST)
    options_to_cmd(options, cmd)
    if manifest
      dump_fontist_manifest_locations(manifest) do |manifest_path|
        cmd << "--font-manifest" << quote(manifest_path)
        mn2pdf(cmd)
      end
    else
      mn2pdf(cmd)
    end
  end

  def self.mn2pdf(cmd)
    cmd = cmd.join(" ")
    puts cmd
    stdout, stderr, status = Open3.capture3(cmd)

    unless status.success?
      puts_error_log(stdout, stderr)

      raise StandardError.new("mn2pdf failed! #{parse_error_msg(stderr)}")
    end
  end

  def self.puts_error_log(stdout, stderr)
    puts ["Fatal error!", "STDOUT:", stdout.strip, "STDERR:", stderr.strip]
      .join("\n")
      .split("\n")
      .map { |line| "[mn2pdf] #{line}" }
      .join("\n")
  end

  def self.parse_error_msg(stderr)
    err = stderr.split("\n").detect { |line| line.start_with? "Error: " }

    err ? err[7..-1] : stderr.strip
  end

  def self.quote(str)
    return "" if str.nil? || str.empty?
    return str if /^'.*'$/.match(str) || /^".*"$/.match(str)

    %("#{str}")
  end

  def self.dump_fontist_manifest_locations(manifest)
    Tempfile.create(["fontist_locations", ".yml"]) do |f|
      f.write manifest.to_yaml
      f.flush

      yield f.path
    end
  end

  def self.options_to_cmd(options, cmd)
    options.each do |k, v|
      sep = k.to_s.end_with?("=") ? "" : " "
      cmd << "#{k}#{sep}#{quote(v)}"
    end
  end
end
