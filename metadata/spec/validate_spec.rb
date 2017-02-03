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
      expect(val).to eq(['Need Title'])
    end
    it "rejects missing composer" do
      @metadata.delete("composer")
      val = validate_piece(@metadata)
      expect(val).to eq(['Need Composer'])
    end
    it "rejects missing voicings" do
      @metadata.delete("voicings")
      val = validate_piece(@metadata)
      expect(val).to eq(['Need at least one Voicing'])
    end



    it "rejects empty title" do
      @metadata["title"] = ""
      val = validate_piece(@metadata)
      expect(val).to eq(['Need Title'])
    end
    it "rejects empty composer" do
      @metadata["composer"] = ""
      val = validate_piece(@metadata)
      expect(val).to eq(['Need Composer'])
    end
    it "rejects dates with non number" do
      @metadata["dates"][0] = 'abc'
      val = validate_piece(@metadata)
      expect(val).to eq(['dates must be integers'])
    end
    it "rejects dates where first number is greater than first" do
      @metadata["dates"][0] = 1500
      @metadata["dates"][1] = 1400
      val = validate_piece(@metadata)
      expect(val).to eq(['second date must be larger than first date'])
    end
    it "rejects dates where more than two numbers are in list" do
      @metadata["dates"][0] = 1400
      @metadata["dates"][1] = 1500
      @metadata["dates"][2] = 1600
      val = validate_piece(@metadata)
      expect(val).to eq(['only two numbers allowed in dates list'])
    end
    it "rejects empty voicings" do
      @metadata["voicings"] = ""
      val = validate_piece(@metadata)
      expect(val).to eq(['Need at least one Voicing'])
    end
    it "rejects empty voicings element" do
      @metadata["voicings"][0] = ""
      val = validate_piece(@metadata)
      expect(val).to eq(['Need at least one Voicing'])
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
        expect(val).to eq(['Must contain only SATB characters'])
      end
      it "rejects voicings with non 'SATB' characters" do
        @metadata["voicings"][1] = "xxx"
        val = validate_piece(@metadata)
        expect(val).to eq(['Must contain only SATB characters'])
      end
    end

  end 
end
describe "validate" do
  context "bad YAML" do
    before(:each) do
      Dir.mkdir("./slug")
      FileUtils.cp 'spec/fixtures/bad.yaml', 'slug/metadata.yaml'
      `touch ./slug/slug.pdf`      
    end
    after(:each) do
      FileUtils.rm_r "./slug" 
    end
    it "rejects bad yaml file" do
      valid, errors = validate
      expect(valid).to be_falsey
      expect(errors[0]).to include('slug')
    end
  end
  context "validate multiple files" do
    before(:each) do
      Dir.mkdir("./slug")
      FileUtils.cp 'spec/fixtures/basic.yaml', 'slug/metadata.yaml'
      `touch ./slug/slug.pdf`      
    end
    after(:each) do
      FileUtils.rm_r "./slug" 
    end
    it "returns OK for good files structure and metadata" do
      valid, errors = validate
      expect(valid).to be_truthy
      expect(errors).to be_nil
    end
    it "rejects missing file" do
      `rm slug/slug.pdf`
      valid, errors = validate
      expect(valid).to be_falsey
      expect(errors[0]).to eq("slug: Need PDF")
    end
  end
end
