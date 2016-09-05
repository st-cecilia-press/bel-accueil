describe "validate" do
  context "basic data" do
    before(:each) do
      @metadata = YAML.load_file('./spec/fixtures/basic.yaml')  
    end
    it "Outputs OK" do
      val = validate(@metadata)
      expect(val).to eq('OK')
    end
    it "rejects empty title" do
      @metadata["title"] = ""
      val = validate(@metadata)
      expect(val).to eq('Fail: Need Title')
    end
    it "rejects empty composer" do
      @metadata["composer"] = ""
      val = validate(@metadata)
      expect(val).to eq('Fail: Need Composer')
    end
    it "rejects empty voicings" do
      @metadata["voicings"] = ""
      val = validate(@metadata)
      expect(val).to eq('Fail: Need at least one Voicing')
    end
    it "rejects empty voicings element" do
      @metadata["voicings"][0] = ""
      val = validate(@metadata)
      expect(val).to eq('Fail: Need at least one Voicing')
    end

    context "voicings character checks" do
      before(:each) do
        @metadata["voicings"][0] = "SATB"
      end
      it "rejects voicings with uncapitalized 'SATB' characters" do
        @metadata["voicings"][1] = "saTB"
        val = validate(@metadata)
        expect(val).to eq('Fail: Must contain only SATB characters')
      end
      it "rejects voicings with non 'SATB' characters" do
        @metadata["voicings"][1] = "xxx"
        val = validate(@metadata)
        expect(val).to eq('Fail: Must contain only SATB characters')
      end
    end
  end 
end
