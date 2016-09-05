describe "validate" do
  context "basic data" do
    before(:each) do
      @metadata = YAML.load_file('./spec/fixtures/basic.yaml')  
      `touch #{@metadata.first["slug"]}.pdf`      
    end
    after(:each) do
      `rm #{@metadata.first["slug"]}.pdf` if File.exist?("#{@metadata.first["slug"]}")
    end
    it "Outputs OK" do
      val = validate(@metadata)
      expect(val).to eq('OK')
    end



    it "rejects missing slug" do
      @metadata.first.delete("slug")
      val = validate(@metadata)
      expect(val).to eq('Error: Need Slug')
    end
    it "rejects missing title" do
      @metadata.first.delete("title")
      val = validate(@metadata)
      expect(val).to eq('Error: slug: Need Title')
    end
    it "rejects missing composer" do
      @metadata.first.delete("composer")
      val = validate(@metadata)
      expect(val).to eq('Error: slug: Need Composer')
    end
    it "rejects missing voicings" do
      @metadata.first.delete("voicings")
      val = validate(@metadata)
      expect(val).to eq('Error: slug: Need at least one Voicing')
    end



    it "rejects empty slug" do
      @metadata.first["slug"] = ""
      val = validate(@metadata)
      expect(val).to eq('Error: Need Slug')
    end
    it "rejects empty title" do
      @metadata.first["title"] = ""
      val = validate(@metadata)
      expect(val).to eq('Error: slug: Need Title')
    end
    it "rejects empty composer" do
      @metadata.first["composer"] = ""
      val = validate(@metadata)
      expect(val).to eq('Error: slug: Need Composer')
    end
    it "rejects empty voicings" do
      @metadata.first["voicings"] = ""
      val = validate(@metadata)
      expect(val).to eq('Error: slug: Need at least one Voicing')
    end
    it "rejects empty voicings element" do
      @metadata.first["voicings"][0] = ""
      val = validate(@metadata)
      expect(val).to eq('Error: slug: Need at least one Voicing')
    end
    it "rejects missing file" do
        `rm #{@metadata.first["slug"]}.pdf`
        val = validate(@metadata)
        expect(val).to eq('Error: slug: Need PDF')
    end

    context "voicings character checks" do
      before(:each) do
        @metadata.first["voicings"][0] = "SATB"
      end
      it "accepts Heterophonic" do
        @metadata.first["voicings"][1] = "Heterophonic"
        val = validate(@metadata)
        expect(val).to eq('OK')
      end
      it "rejects voicings with uncapitalized 'SATB' characters" do
        @metadata.first["voicings"][1] = "saTB"
        val = validate(@metadata)
        expect(val).to eq('Error: slug: Must contain only SATB characters')
      end
      it "rejects voicings with non 'SATB' characters" do
        @metadata.first["voicings"][1] = "xxx"
        val = validate(@metadata)
        expect(val).to eq('Error: slug: Must contain only SATB characters')
      end
    end

  end 
end
describe "files_in_metadata" do
  context "basic data" do
    before(:each) do
      @metadata = YAML.load_file('./spec/fixtures/basic.yaml')  
      `touch #{@metadata.first["slug"]}.pdf`      
    end
    after(:each) do
      `rm #{@metadata.first["slug"]}.pdf` if File.exist?("#{@metadata.first["slug"]}")
    end
    it "passes if slug.pdf is in metadata" do
      result = files_in_metadata(@metadata)
      expect(result).to eq('OK') 
    end
    it "rejects if slug.pdf is not in metadata" do
      @metadata.first["slug"] = 'definitelynottheslug'
      result = files_in_metadata(@metadata)
      expect(result).to eq('Error: slug.pdf not in metadata')
    end
  end
end
