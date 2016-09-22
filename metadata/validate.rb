require 'byebug'
require 'yaml'
require 'uri'
require "net/http"

def validate 
  errors = []
  directories = Dir.glob('*').select {|f| File.directory? f and f !=  "spec" and f != "metadata"}
  directories.each do |slug|
    metadata = YAML.load_file("#{slug}/metadata.yaml")
    errors.push("#{slug}: Need PDF") unless File.exist?("#{slug}/#{slug}.pdf")
    output = validate_piece(metadata)
    unless output == 'OK'
      errors.push("#{slug}: #{output}")
    end
  end
  if errors.empty?
    return 'OK'
  else
    return "Errors: #{errors}"
  end
end
def validate_piece(piece)
  errors = []  
  errors.push("Need Title") if piece['title'].nil? or  piece['title'].empty? 
  errors.push("Need Composer") if  piece['composer'].nil? or piece["composer"].empty?
  if  piece['voicings'].nil? or piece["voicings"].empty? or piece["voicings"].all? {|i| i.nil? or i == ""}
    errors.push("Need at least one Voicing") 
  else
    piece["voicings"].each do |voicing| 
      if voicing != 'Heterophonic'
        errors.push("Must contain only SATB characters") if voicing !~ /^[SATB]+$/
      end
    end
  end
  if errors.empty?
    return 'OK'
  else 
    return errors
  end
end
