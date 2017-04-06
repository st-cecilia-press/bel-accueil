require 'fileutils'
require 'tempfile'
require 'elif'

#directories = Dir.glob('*').select {|f| File.directory? f and f != "test" and f !=  "metadata" }
directories = ['a_madre_do_que_a_bestia', 'acorrer-nos_pode_e_de_mal_guardar', 'gran_piadad_e_mercee_e_nobreza',
'quena_virgen_ben_servira', 'santa_maria_strela_do_dia', 'sieus_quier_conseill_bel_amig_alamanda']

directories.each do |slug|
  puts slug
  puts `iconv -f UTF-8 ./#{slug}/lyrics.csv -o /dev/null`
  #if File.exists? "./#{slug}/lyrics.csv"
  #  t_file = Tempfile.new('filename_temp.txt')
  #  file_array = []
  #  Elif.open("./#{slug}/lyrics.csv").each_line do |l|
  #    file_array.push(l)
  #  end
  #  file_array.each_with_index do |row, i|
  #    if i == 0 and row =~ /[^\s,]/
  #      break;
  #    elsif file_array[i+1] =~ /[^\s,]/ and row =~ /^[\s,]+$/
  #      file_array.slice!(0,i+1) 
  #      break
  #    end
  #  end

  #  file_array.reverse.each do |l|
  #    t_file.puts l
  #  end
  #  t_file.close
  #  
  #  #FileUtils.mv(t_file.path, "test/#{slug}.csv")
  #  FileUtils.mv(t_file.path, "#{slug}/lyrics.csv")
  #end 
  #`iconv -f WINDOWS-1254 -t UTF-8 -o ./#{slug}/out.csv ./#{slug}/lyrics.csv`
  #FileUtils.mv "./#{slug}/out.csv", "./#{slug}/lyrics.csv"
end



