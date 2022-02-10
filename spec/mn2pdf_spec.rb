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

  it "test font manifest hash options" do
    Dir.mktmpdir do |dir|
      pdf_path = File.join(dir, "G.191.pdf")
      Mn2pdf.convert(sample_xml, pdf_path, sample_xsl,
                     font_manifest: font_manifest)
      expect(File.exist?(pdf_path)).to be true
    end
  end

  it "test font manifest str options" do
    Dir.mktmpdir do |dir|
      pdf_path = File.join(dir, "G.191.pdf")
      font_manifest_file = File.join(dir, "fm.yaml")
      File.write(font_manifest_file, font_manifest.to_yaml)
      Mn2pdf.convert(sample_xml, pdf_path, sample_xsl,
                     "--font-manifest #{font_manifest_file}")
      expect(File.exist?(pdf_path)).to be true
    end
  end

  it "no uncecessary spaces for parameters which ends with equals" do
    status = double
    allow(status).to receive(:success?).and_return(true)
    expect(Open3).to receive(:capture3) do |arg|
      expect(arg).to include '--param baseassetpath="sources"'
      expect(arg).to include '--font-manifest "fontist_locations.yml"'
    end.and_return(["", "", status])
    Mn2pdf.convert("document.presentation.xml", "document.pdf",
                   "ogc.engineering-report.xsl",
                   { "--param baseassetpath=": "sources",
                     "--font-manifest": "fontist_locations.yml" })
  end

  let(:sample_xsl) do
    Pathname.new(File.dirname(__dir__))
      .join("spec", "fixtures", "itu.recommendation.xsl").to_s
  end

  let(:sample_xml) do
    Pathname.new(File.dirname(__dir__))
      .join("spec", "fixtures", "G.191.xml").to_s
  end

  let(:font_manifest) do
    fonts = File.join(ENV["HOME"], ".fontist", "fonts")
    {
      "Cambria Math" => {
        "Regular" => {
          "full_name" => "Cambria Math",
          "paths" => ["#{fonts}/CAMBRIA.ttc"],
        },
      },
      "Times New Roman" => {
        "Bold Italic" => {
          "full_name" => "Times New Roman Bold Italic",
          "paths" => ["#{fonts}/TimesBI.ttf"],
        },
        "Italic" => {
          "full_name" => "Times New Roman Italic",
          "paths" => ["#{fonts}/TimesI.ttf"],
        },
        "Regular" => {
          "full_name" => "Times New Roman",
          "paths" => ["#{fonts}/Times.ttf"],
        },
        "Bold" => {
          "full_name" => "Times New Roman Bold",
          "paths" => ["#{fonts}/TimesBd.ttf"],
        },
      },
    }
  end
end
