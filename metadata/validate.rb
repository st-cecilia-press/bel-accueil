require 'yaml'
require 'uri'
require "net/http"

class Validator
  def initialize(url=false, book_yaml='./include/books.yaml', manuscript_yaml='./include/manuscripts.yaml')
    @url = url
    @directories = Dir.glob('*').select {|f| File.directory? f and f !=  "spec" and f != "metadata" and f != 'test' and f!= 'include'}
    @errors = []
    @book_yaml = book_yaml
    @manuscript_yaml = manuscript_yaml
  end

  def validate_repo
    @directories.each do |slug|
      yaml = "#{slug}/metadata.yaml"
      valid, message = valid_yaml_string?(yaml)
      if !valid
        @errors.push(message)
        next
      end
      metadata = YAML.load_file(yaml)
      @errors.push("#{slug}: Need PDF") unless File.exist?("#{slug}/#{slug}.pdf")
      output = validate(metadata, slug)
      unless output == 'OK'
        @errors.push("#{slug}: #{output}")
      end
    end
    if @errors.empty?
      return true
    else
      return false, @errors 
    end
  end

  def valid_yaml_string?(yaml)
    begin
      !!YAML.load_file(yaml)
    rescue Exception => e
      return false, e.message
    end
  end

  def validate(metadata, slug)
  
    my_errors = []
    my_errors.push('Need Title') if metadata["title"].nil? or metadata["title"].empty? 
    my_errors.push('Need Composer') if metadata["composer"].nil? or metadata["composer"].empty?
    if metadata['dates']
      my_errors.push('dates must exist') if metadata['dates'].nil? or metadata['dates'].empty?
      metadata['dates'].each do | date |
        my_errors.push('dates must be integers') unless date.is_a? Integer
      end
      my_errors.push('second date must be larger than first date') if metadata['dates'].count >1 && metadata['dates'][0] > metadata['dates'][1]
      my_errors.push('only two numbers allowed in dates list') if metadata['dates'].count > 2
    end
    if metadata["voicings"].nil? or metadata["voicings"].empty? or metadata["voicings"].all? {|i| i.nil? or i == ""}
      my_errors.push('Need at least one Voicing') 
    else
      Array(metadata["voicings"]).each do |voicing| 
        if voicing != 'Heterophonic' 
          my_errors.push('Must contain only SATB characters') if voicing !~ /^[SATB]+$/
        end
      end
    end

    Array(metadata["manuscripts"]).each do |man|
      my_errors.push('Need Manuscript Name') if man["name"].empty?
      manuscripts = YAML.load_file(@manuscript_yaml) 
      my_errors.push('manuscript name not in includes/manuscripts.yaml') unless manuscripts.detect { |m| m['name'] == man['name']}
      my_errors += image_error?(Array(man["images"]),slug)
    end 
    Array(metadata["books"]).each do |man|
      my_errors = []
      my_errors.push('Need Book Slug') if man["slug"].empty?
      books = YAML.load_file(@book_yaml) 
      my_errors.push('book slug not in includes/books.yaml') unless books.detect { |b| b['slug'] == man['slug']}
    
      my_errors += image_error?(Array(man["images"]),slug)
    end 
    if my_errors.empty?
      return 'OK'
    else
      return my_errors
    end
  end
  def image_error?(images, slug)
    errors = []
    images.each do |img|
      errors.push('Image must have URL') if img["url"].empty? 
      errors.push('Image must have Filename') if img["filename"].empty? 
      errors.push("'#{img["filename"]}' doesn't exist") unless File.exists?("./#{slug}/#{img["filename"]}")
      if @url && !img["url"].empty? && img["url"] !~ /proquest/ 
        errors.push("'#{img["url"]}' doesn't resolve") unless url_resolves?(img["url"])
      end
    end  
    return errors 
  end
  def url_resolves?(url_text)
    uri = URI.parse(url_text)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.request_head(uri.path) 
    http.start do
      path = (uri.path.empty?) ? '/' : uri.path
      http.request_get(path) do |response|
        case response
        when Net::HTTPSuccess then
           return true
        when Net::HTTPRedirection then
           return true
        else
          return false
        end
      end
    end
  end
end


#def validate 
#  errors = []
#  directories = Dir.glob('*').select {|f| File.directory? f and f !=  "spec" and f != "metadata" and f != 'test'}
#  directories.each do |slug|
#
#    yaml = "#{slug}/metadata.yaml"
#    valid, message = valid_yaml_string?(yaml)
#    if !valid
#      errors.push(message)
#      next
#    end
#    metadata = YAML.load_file(yaml)
#    errors.push("#{slug}: Need PDF") unless File.exist?("#{slug}/#{slug}.pdf")
#    output = validate_piece(metadata)
#    unless output == 'OK'
#      errors.push("#{slug}: #{output}")
#    end
#  end
#  if errors.empty?
#    return true
#  else
#    return false, errors 
#  end
#end
#def validate_piece(piece)
#  errors = []  
#  errors.push("Need Title") if piece['title'].nil? or  piece['title'].empty? 
#  errors.push("Need Composer") if  piece['composer'].nil? or piece["composer"].empty?
#  if piece['dates']
#    errors.push ('dates must exist') if piece['dates'].empty?
#    piece['dates'].each do | date |
#      errors.push ('dates must be integers') unless date.is_a? Integer
#    end
#    errors.push ('second date must be larger than first date') if piece['dates'].count >1 && piece['dates'][0] > piece['dates'][1]
#    errors.push('only two numbers allowed in dates list') if piece['dates'].count > 2
#  end
#  if  piece['voicings'].nil? or piece["voicings"].empty? or piece["voicings"].all? {|i| i.nil? or i == ""}
#    errors.push("Need at least one Voicing") 
#  else
#    piece["voicings"].each do |voicing| 
#      if voicing != 'Heterophonic'
#        errors.push("Must contain only SATB characters") if voicing !~ /^[SATB]+$/
#      end
#    end
#  end
#  if errors.empty?
#    return 'OK'
#  else 
#    return errors
#  end
#end
#
#def valid_yaml_string?(yaml)
#  begin
#    !!YAML.load_file(yaml)
#  rescue Exception => e
#    return false, e.message
#  end
#end
