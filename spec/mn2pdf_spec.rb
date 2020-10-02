require 'tmpdir'

RSpec.describe Mn2pdf do

=begin
  There is no reason why the gem version must equal the JAR version. Rescinded 
  it 'matches the version number of JAR' do
    expect(Mn2pdf::VERSION).to eq(Mn2pdf.version)
  end
=end

  it 'converts XML to PDF' do

    Dir.mktmpdir do |dir|
      pdf_path = File.join(dir, 'G.191.pdf')

      Mn2pdf.convert(sample_xml, pdf_path, sample_xsl)
      expect(File.exist?(pdf_path)).to be true
    end

  end

  let(:sample_xsl) do
    Pathname.new(File.dirname(__dir__)).
    join('spec', 'fixtures', 'itu.recommendation.xsl').to_s
  end

  let(:sample_xml) do
    Pathname.new(File.dirname(__dir__)).
    join('spec', 'fixtures', 'G.191.xml').to_s
  end

end
