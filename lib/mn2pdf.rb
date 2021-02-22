require 'open3'
require 'rbconfig'
require 'mn2pdf/version'

module Mn2pdf
  MN2PDF_JAR_PATH = File.join(File.dirname(__FILE__), '../bin/mn2pdf.jar')

  def self.help
    cmd = ['java', '-jar', MN2PDF_JAR_PATH].join(' ')
    message, error_str, status = Open3.capture3(cmd)
    message
  end

  def self.version
    cmd = ['java', '-jar', MN2PDF_JAR_PATH, '-v'].join(' ')
    message, error_str, status = Open3.capture3(cmd)
    message.strip
  end

  def self.jvm_options
    options = ['-Xss5m', '-Xmx1024m']

    if RbConfig::CONFIG['host_os'].match?(/darwin|mac os/)
      options << '-Dapple.awt.UIElement=true'
    end

    options
  end

  def self.convert(url_path, output_path, xsl_stylesheet, options = "")
    return if url_path.nil? || output_path.nil? || xsl_stylesheet.nil?

    puts MN2PDF_JAR_PATH
    cmd = ['java', *jvm_options, '-jar', MN2PDF_JAR_PATH, '--xml-file',
           url_path, '--xsl-file', xsl_stylesheet, '--pdf-file',
           output_path, options].join(' ')

    puts cmd
    stdout_str, error_str, status = Open3.capture3(cmd)

    unless status.success?
      # Strip default mn2pdf message
      stdout_str = stdout_str.gsub('Preparing...', '').strip
      raise [stdout_str, error_str].join(' ').strip
    end
  end
end
