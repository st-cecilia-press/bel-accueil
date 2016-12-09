require_relative 'validate'

valid, errors =  validate
if valid
  puts 'OK'
else
  puts 'Errors: '
  errors.each do |error|
    puts error
  end
end
