require "open3"
require "rbconfig"
require "mn2pdf/version"

module Mn2pdf
  MN2PDF_JAR_PATH = File.join(File.dirname(__FILE__), "../bin/mn2pdf.jar")
  DEFAULT_JAVA_OPTS = ["-Xss5m", "-Xmx2048m"]

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
    blank_message, help_message, = Open3.capture3(cmd)
    help_message
  end

  def self.version
    cmd = ["java", *jvm_options, "-jar", MN2PDF_JAR_PATH, "-v"].join(" ")
    message, = Open3.capture3(cmd)
    message.strip
  end

  def self.convert(url_path, output_path, xsl_stylesheet, options = "")
    return if url_path.nil? || output_path.nil? || xsl_stylesheet.nil?

    cmd = ["java", *jvm_options,
           "-jar", MN2PDF_JAR_PATH,
           "--xml-file", url_path,
           "--xsl-file", xsl_stylesheet,
           "--pdf-file", output_path, options].join(" ")

    puts cmd
    stdout_str, error_str, status = Open3.capture3(cmd)

    raise prepare_error_msg(stdout_str, error_str) unless status.success?
  end

  def self.prepare_error_msg(stdout_str, error_str)
    # Strip default mn2pdf message
    stdout_str = stdout_str.gsub("Preparing...", "").strip
    ["[mn2pdf] Fatal:", stdout_str, error_str].join(" ").strip
  end
end
