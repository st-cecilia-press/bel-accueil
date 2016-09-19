require 'fileutils'
require 'csv'
require 'yaml'
CSV.foreach('./pieces_list.csv')do |row|
  next if row[0] == 'Slug' 
  hash = Hash.new
  hash['title'] = row[1]
  hash['composer'] = row[2]
  hash['voicings'] = row[3].split(', ') unless row[3].nil?
  hash['source'] = row[4]
  hash['first_line_of_translation'] = row[5]
  hash['lyricist'] = row[6]
  hash['language'] = row[7].split(', ') unless row[7].nil?
  hash['century'] = row[8]
  hash['tags'] = row[9].split(', ') unless row[9].nil?
  hash['notes'] = row[10]

  slug = row[0]
  Dir.mkdir(slug)
  File.open("./#{slug}/metadata.yaml", 'w'){ |f|
      f.puts hash.to_yaml
  }
  FileUtils.mv("./#{slug}.pdf", "./#{slug}/#{slug}.pdf")
end

