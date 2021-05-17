require "tmpdir"

RSpec.describe Mn2pdf do
  it "gem version more or equal to JAR version" do
    gem_version = Gem::Version.new(Mn2pdf::VERSION)
    expect(gem_version).to be >= Gem::Version.new(Mn2pdf.version)
  end

  it "help not empty" do
    expect(Mn2pdf.help).not_to be_empty
  end

  it "converts XML to PDF" do
    Dir.mktmpdir do |dir|
      pdf_path = File.join(dir, "G.191.pdf")

      Mn2pdf.convert(sample_xml, pdf_path, sample_xsl)
      expect(File.exist?(pdf_path)).to be true
    end
  end

  it "raise an error on converting not existing XML" do
    pdf_path = "missing.pdf"
    xml_path = "missing.xml"
    expect do
      Mn2pdf.convert(xml_path, pdf_path, sample_xsl)
    end.to raise_error(/XML file '#{xml_path}' not found!/)
    expect(File.exist?(pdf_path)).to be false
  end

  let(:sample_xsl) do
    Pathname.new(File.dirname(__dir__))
      .join("spec", "fixtures", "itu.recommendation.xsl").to_s
  end

  let(:sample_xml) do
    Pathname.new(File.dirname(__dir__))
      .join("spec", "fixtures", "G.191.xml").to_s
  end
end
