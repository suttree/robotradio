require 'nokogiri'
require 'open-uri'

class DailyInspirationWorker
  def self.create
    puts "Searching with daily inspiration"
    doc = Nokogiri::HTML(open('http://www.dailyinspirationalquotes.in/', :allow_redirections => :safe))
    links = doc.css('a[rel=bookmark]')
    link = links[rand(links.length)].attributes['href'].to_s
    StoryWorker.delay.create(link) if link
  end
end
