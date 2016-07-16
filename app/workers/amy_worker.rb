require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

class AmyWorker
  def self.create
    puts "Searching with amy"
    doc = Nokogiri::HTML(open('http://amyhref.com', :allow_redirections => :safe))
    links = doc.css('.links a')
    link = links[rand(links.length)].attributes['href'].to_s
    StoryWorker.delay.create(link) if link.present?
  end
end
