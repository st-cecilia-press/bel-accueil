describe "validate_piece" do
  context "basic data" do
    before(:each) do
      @metadata = YAML.load_file('./spec/fixtures/basic.yaml')  
    end
    after(:each) do
    end
    it "Outputs OK" do
      val = validate_piece(@metadata)
      expect(val).to eq('OK')
    end



    it "rejects missing title" do
      @metadata.delete("title")
      val = validate_piece(@metadata)
      expect(val).to eq('Need Title')
    end
    it "rejects missing composer" do
      @metadata.delete("composer")
      val = validate_piece(@metadata)
      expect(val).to eq('Need Composer')
    end
    it "rejects missing voicings" do
      @metadata.delete("voicings")
      val = validate_piece(@metadata)
      expect(val).to eq('Need at least one Voicing')
    end



    it "rejects empty title" do
      @metadata["title"] = ""
      val = validate_piece(@metadata)
      expect(val).to eq('Need Title')
    end
    it "rejects empty composer" do
      @metadata["composer"] = ""
      val = validate_piece(@metadata)
      expect(val).to eq('Need Composer')
    end
    it "rejects empty voicings" do
      @metadata["voicings"] = ""
      val = validate_piece(@metadata)
      expect(val).to eq('Need at least one Voicing')
    end
    it "rejects empty voicings element" do
      @metadata["voicings"][0] = ""
      val = validate_piece(@metadata)
      expect(val).to eq('Need at least one Voicing')
    end

    context "voicings character checks" do
      before(:each) do
        @metadata["voicings"][0] = "SATB"
      end
      it "accepts Heterophonic" do
        @metadata["voicings"][1] = "Heterophonic"
        val = validate_piece(@metadata)
        expect(val).to eq('OK')
      end
      it "rejects voicings with uncapitalized 'SATB' characters" do
        @metadata["voicings"][1] = "saTB"
        val = validate_piece(@metadata)
        expect(val).to eq('Must contain only SATB characters')
      end
      it "rejects voicings with non 'SATB' characters" do
        @metadata["voicings"][1] = "xxx"
        val = validate_piece(@metadata)
        expect(val).to eq('Must contain only SATB characters')
      end
    end

  end 
end
describe "validate" do
  before(:each) do
    Dir.mkdir("./slug")
    FileUtils.cp 'spec/fixtures/basic.yaml', 'slug/metadata.yaml'
    `touch ./slug/slug.pdf`      
  end
  after(:each) do
    FileUtils.rm_r "./slug" 
  end
  it "returns OK for good files structure and metadata" do
    val = validate
    expect(val).to eq('OK')
  end
  it "rejects missing file" do
    `rm slug/slug.pdf`
    val = validate
    expect(val).to eq('Error: slug: Need PDF')
  end
end
