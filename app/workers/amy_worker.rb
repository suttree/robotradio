require 'nokogiri'
require 'open-uri'

class AmyWorker
  def self.create
    doc = Nokogiri::HTML(open('http://amyhref.com'))
    links = doc.css('.links a')
    link = links[rand(links.length)].attributes['href'].to_s
    StoryWorker.create(link)
  end
end
