require 'rubygems'
require 'kramdown'
require 'cgi'

require 'rexml/parsers/baseparser'
require 'kramdown/converter/backlog'

if ARGV.size != 1 then
  puts "ruby convert.rb [markdown file]"
  exit
end

filename = ARGV[0]
mdown_src = File.read(filename)
puts Kramdown::Document.new(mdown_src).to_backlog
