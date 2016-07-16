require 'nokogiri'
require 'open-uri'

class TinyAssistantWorker
  def self.create
    puts "Searching with tinyassistant"
    doc = Nokogiri::HTML(open('https://twitter.com/TinyAssistant', :allow_redirections => :safe))
    links = doc.css('a.twitter-timeline-link')
    link = links[rand(links.length)].attributes['href'].to_s
    StoryWorker.delay.create(link) if link.present?
  end
end
