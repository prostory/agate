Dir["#{File.expand_path('../',  __FILE__)}/agate/**/*.rb"].uniq.each do |filename|
  require filename if filename.include? ".rb"
end
