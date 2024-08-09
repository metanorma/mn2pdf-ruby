RSpec.describe Jvm do
  def with_env_vars(env_vars)
    original_env = ENV.to_hash
    ENV.update(env_vars)
    yield
  ensure
    ENV.replace(original_env)
  end

  it "default stack size" do
    expect(Jvm.options).to include("-Xss10m")
  end

  it "default heap size" do
    expect(Jvm.options).to include("-Xmx3g")
  end

  it "headless" do
    expect(Jvm.options).to include("-Djava.awt.headless=true")
  end

  it "minimal stack size" do
    with_env_vars("JAVA_OPTS" => "-Xss5m") do
      expect(Jvm.options).to include("-Xss10m")
    end
  end

  it "minimal heap size" do
    with_env_vars("JAVA_OPTS" => "-Xmx1g") do
      expect(Jvm.options).to include("-Xmx3072m")
    end
  end

  it "custom stack size" do
    with_env_vars("JAVA_OPTS" => "-Xss15m") do
      expect(Jvm.options).to include("-Xss15m")
    end
  end

  it "custom heap size" do
    with_env_vars("JAVA_OPTS" => "-Xmx5g") do
      expect(Jvm.options).to include("-Xmx5g")
    end
  end
end
