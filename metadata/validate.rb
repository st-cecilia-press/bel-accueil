require 'byebug'
require 'yaml'
require 'uri'
require "net/http"

def validate 
  directories = Dir.glob('*').select {|f| File.directory? f and f !=  "spec" and f != "metadata"}
  directories.each do |slug|
    metadata = YAML.load_file("#{slug}/metadata.yaml")
    return "Error: #{slug}: Need PDF" unless File.exist?("#{slug}/#{slug}.pdf")
    output = validate_piece(metadata)
    unless output == 'OK'
      return "Error: #{slug}: #{output}"
    end
  end
  return 'OK'
end
def validate_piece(piece)
    
  return "Need Title" if piece['title'].nil? or  piece['title'].empty? 
  return "Need Composer" if  piece['composer'].nil? or piece["composer"].empty?
  return "Need at least one Voicing" if  piece['voicings'].nil? or piece["voicings"].empty? or piece["voicings"].all? {|i| i.nil? or i == ""}

  piece["voicings"].each do |voicing| 
    if voicing != 'Heterophonic'
      return "Must contain only SATB characters" if voicing !~ /^[SATB]+$/
    end
  end
  return 'OK'
end
