require "open3"
require "rbconfig"
require "tempfile"
require "yaml"

require "mn2pdf/jvm"

module Mn2pdf
  FONTS_MANIFEST = :font_manifest

  def self.help
    # help message goes to STDERR (from mn2pdf v1.36)
    _, help_message, = Jvm.run
    help_message
  end

  def self.version
    message, = Jvm.run(%w[-v])
    message.strip
  end

  def self.convert(url_path, output_path, xsl_stylesheet, options = {})
    args = build_args(url_path, output_path, xsl_stylesheet)

    return unless args

    case options
    when String
      mn2pdf(args + [options])
    when Hash
      mn2pdf_hash(args, options)
    else
      warn "Unsupported options type #{options.class}"
    end
  end

  def self.build_args(url, output, xslt)
    return if url.nil? || output.nil? || xslt.nil?

    ["--xml-file", quote(url),
     "--xsl-file", quote(xslt),
     "--pdf-file", quote(output)]
  end

  def self.mn2pdf_hash(args, options)
    manifest = options.delete(FONTS_MANIFEST)
    options_to_cmd(options, args)
    if manifest
      dump_fontist_manifest_locations(manifest) do |manifest_path|
        args << "--font-manifest" << quote(manifest_path)
        mn2pdf(args)
      end
    else
      mn2pdf(args)
    end
  end

  def self.mn2pdf(args)
    stdout, stderr, status = Jvm.run(args)

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
