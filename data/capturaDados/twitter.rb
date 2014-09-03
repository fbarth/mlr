#
# forma de uso: ruby twitter.rb > mensagens.csv
#

require 'rubygems'
require 'json'

content = File.open('aboutVagas.txt')
content.each do |line|
	puts JSON.parse(line)['text']
end
