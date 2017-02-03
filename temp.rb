require 'fileutils'
require 'yaml'

directories = Dir.glob('*').select {|f| File.directory? f and f != "test" and f !=  "metadata"}

directories.each do |slug|
  hash = YAML.load_file("./#{slug}/metadata.yaml")
  century = hash['century']
  if century
    hash['dates'] = []
    cen = century.split('-')
    if cen.count == 1
      num = cen[0].scan(/\d+/).first
      hash['dates'][0] = (num.to_i - 1) * 100
      hash['dates'][1] = ((num.to_i - 1) * 100) + 99
    else
      num1 = cen[0].scan(/\d+/).first
      num2 = cen[1].scan(/\d+/).first
      hash['dates'][0] = (num1.to_i - 1) * 100
      hash['dates'][1] = ((num2.to_i - 1) * 100) + 99
    end
    
  end

  metadata = Hash.new
  metadata['title'] = hash['title']
  metadata['composer'] = hash['composer']
  metadata['dates'] = hash['dates']
  metadata['voicings'] = hash['voicings']
  metadata['source'] = hash['source']
  metadata['first_line_of_translation'] = hash['first_line_of_translation']
  metadata['lyricist'] = hash['lyricist']
  metadata['language'] = hash['language']
  metadata['century'] = hash['century']
  metadata['tags'] = hash['tags']
  metadata['notes'] = hash['notes']
  
  File.open("./#{slug}/metadata.yaml", 'w'){ |f|
      f.puts metadata.to_yaml
  }

end



