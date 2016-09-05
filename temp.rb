require 'csv'
require 'yaml'
metadata = Array.new
CSV.foreach('./!List of all pieces.csv')do |row|
  next if row[0] == 'Slug' 
  hash = Hash.new
  hash['slug'] = row[0]
  hash['title'] = row[1]
  hash['composer'] = row[2]
  hash['voicings'] = row[3].split(', ') unless row[3].nil?
  hash['source'] = row[4]
  hash['first_line_of_translation'] = row[5]
  hash['lyricist'] = row[6]
  hash['language'] = row[7]
  hash['century'] = row[8]
  hash['tags'] = row[9].split(', ') unless row[9].nil?
  hash['notes'] = row[10]

  metadata.push(hash)
end

File.open('./metadata.yaml', 'w'){ |f|
    f.puts metadata.to_yaml
}
