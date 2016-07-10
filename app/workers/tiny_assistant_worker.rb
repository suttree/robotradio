require 'nokogiri'
require 'open-uri'

class TinyAssistantWorker
  def self.create
    if (rand(5) > 2 )
      doc = Nokogiri::HTML(open('https://twitter.com/TinyAssistant'))
      links = doc.css('a.twitter-timeline-link')
      link = links[rand(links.length)].attributes['href'].to_s
      StoryWorker.delay.create(link) if link
    end
  end
end
