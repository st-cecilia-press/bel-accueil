require 'byebug'
require 'yaml'
require 'uri'
require "net/http"

def validate(metadata) 
  metadata.each do |piece|
    output = validate_piece(piece)
    return "Error: #{output}" if output =~ /Slug/
    unless output == 'OK'
      return "Error: #{piece["slug"]}: #{output}"
    end
  end
  return 'OK'
end
def validate_piece(piece)
    
  return "Need Slug" if piece['slug'].nil? or piece['slug'].empty?
  return "Need PDF" unless File.exist?("#{piece['slug']}.pdf")
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
def files_in_metadata(metadata)
  files = Dir['./*.pdf']
  files.each do |file|
    slug = File.basename(file, '.pdf')
    next if slug !~ /^[a-z]/
    return "Error: #{slug}.pdf not in metadata" unless metadata.detect{|m| m["slug"] == slug}
  end
  return 'OK'
end
