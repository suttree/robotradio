require 'nokogiri'
require 'open-uri'

class AmyWorker
  def self.create
    if (rand(5) > 2 )
      doc = Nokogiri::HTML(open('http://amyhref.com'))
      links = doc.css('.links a')
      link = links[rand(links.length)].attributes['href'].to_s
      StoryWorker.delay.create(link) if link
    end
  end
end
