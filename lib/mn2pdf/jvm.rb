require "open3"
require "pathname"
require "rbconfig"

module Jvm
  MN2PDF_JAR_PATH = Pathname.new(__FILE__)
    .dirname
    .join("../../bin/mn2pdf.jar")
    .realpath
  DEFAULT_JAVA_OPTS = %w[-Xss10m -Xmx3g -Djava.awt.headless=true].freeze

  def self.to_bytes(value)
    case value[-1].downcase
    when "k"
      value.to_i * 1024
    when "m"
      value.to_i * 1024 * 1024
    when "g"
      value.to_i * 1024 * 1024 * 1024
    else
      value.to_i
    end
  end

  def self.ensure_java_opts(opts, key, min_value_bytes)
    flag, idx = opts.each_with_index.find { |opt, _| opt.start_with?(key) }
    if flag
      flag_value_bytes = to_bytes(flag[key.length..-1])

      if flag_value_bytes < min_value_bytes
        min_value_str = "#{key}#{min_value_bytes / (1024 * 1024)}m"
        opts[idx] = min_value_str
      end
    else
      opts << "#{key}#{min_value_bytes / (1024 * 1024)}m"
    end
  end

  def self.options
    result = ENV["JAVA_OPTS"]&.split || DEFAULT_JAVA_OPTS.dup

    ensure_java_opts(result, "-Xss", to_bytes("10m"))
    ensure_java_opts(result, "-Xmx", to_bytes("3g"))

    if RbConfig::CONFIG["host_os"].match?(/darwin|mac os/)
      result << "-Dapple.awt.UIElement=true"
    end

    result << "-Duser.home=#{Dir.home}"

    result
  end

  def self.run(args = [])
    cmd = ["java", *options, "-jar", MN2PDF_JAR_PATH, *args].join(" ")
    puts cmd
    stdout, stderr, status = Open3.capture3(cmd)
    [stdout, stderr, status]
  end
end
