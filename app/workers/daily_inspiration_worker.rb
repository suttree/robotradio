require 'nokogiri'
require 'open-uri'

class DailyInspirationWorker
  def self.create
    if (rand(5) > 0 )
      doc = Nokogiri::HTML(open('http://www.dailyinspirationalquotes.in/'))
      links = doc.css('a[rel=bookmark]')
      link = links[rand(links.length)].attributes['href'].to_s
      StoryWorker.delay.create(link) if link
    end
  end
end
