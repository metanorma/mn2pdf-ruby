require "open3"
require "rbconfig"
require "tempfile"
require "yaml"

require "mn2pdf/version"

module Mn2pdf
  MN2PDF_JAR_PATH = File.join(File.dirname(__FILE__), "../bin/mn2pdf.jar")
  DEFAULT_JAVA_OPTS = ["-Xss5m", "-Xmx2048m"].freeze
  FONTS_MANIFEST = :font_manifest

  def self.jvm_options
    options = DEFAULT_JAVA_OPTS.dup

    if RbConfig::CONFIG["host_os"].match?(/darwin|mac os/)
      options << "-Dapple.awt.UIElement=true"
    end

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
      cmd << options

      mn2pdf(cmd)
    when Hash
      manifest = options.delete(FONTS_MANIFEST)

      options.each do |k, v|
        sep = k.to_s.end_with?("=") ? "" : " "
        cmd << "#{k}#{sep}#{quote(v)}"
      end
      if manifest
        dump_fontist_manifest_locations(manifest) do |manifest_path|
          cmd << "--font-manifest" << quote(manifest_path)
          mn2pdf(cmd)
        end
      else
        mn2pdf(cmd)
      end
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

  def self.mn2pdf(cmd)
    cmd = cmd.join(" ")
    puts cmd
    out, err, status = Open3.capture3(cmd)

    raise prepare_error_msg(out, err) unless status.success?
  end

  def self.prepare_error_msg(stdout, stderr)
    # Strip default mn2pdf message
    stdout = stdout.gsub("Preparing...", "").strip
    ["[mn2pdf] Fatal:", stdout, stderr].join(" ").strip
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
end
