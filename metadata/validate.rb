require 'yaml'
require 'uri'
require "net/http"

def validate 
  errors = []
  directories = Dir.glob('*').select {|f| File.directory? f and f !=  "spec" and f != "metadata"}
  directories.each do |slug|

    yaml = "#{slug}/metadata.yaml"
    valid, message = valid_yaml_string?(yaml)
    if !valid
      errors.push(message)
      next
    end
    metadata = YAML.load_file(yaml)
    errors.push("#{slug}: Need PDF") unless File.exist?("#{slug}/#{slug}.pdf")
    output = validate_piece(metadata)
    unless output == 'OK'
      errors.push("#{slug}: #{output}")
    end
  end
  if errors.empty?
    return true
  else
    return false, errors 
  end
end
def validate_piece(piece)
  errors = []  
  errors.push("Need Title") if piece['title'].nil? or  piece['title'].empty? 
  errors.push("Need Composer") if  piece['composer'].nil? or piece["composer"].empty?
  if piece['dates']
    piece['dates'].each do | date |
      errors.push ('dates must be integers') unless date.is_a? Integer
    end
    errors.push ('second date must be larger than first date') if piece['dates'].count >1 && piece['dates'][0] > piece['dates'][1]
    errors.push('only two numbers allowed in dates list') if piece['dates'].count > 2
  end
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

def valid_yaml_string?(yaml)
  begin
    !!YAML.load_file(yaml)
  rescue Exception => e
    return false, e.message
  end
end
