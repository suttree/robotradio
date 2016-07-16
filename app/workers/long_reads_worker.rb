require 'nokogiri'
require 'open-uri'

class LongReadsWorker
  def self.create
    puts "Searching with longreads 1"
    doc = Nokogiri::HTML(open('http://www.theatlantic.com/category/longreads/', :allow_redirections => :safe))
    links = doc.css('div.body a[data-omni-click]')
    link = links[rand(links.length)].attributes['href'].to_s
    StoryWorker.delay.create(link) if link

    puts "Searching with longreads 2"
    doc = Nokogiri::HTML(open('http://www.newstatesman.com/long-reads', :allow_redirections => :safe))
    links = doc.css('ul.article-list h2 a')
    link = links[rand(links.length)].attributes['href'].to_s
    StoryWorker.delay.create(link) if link
  end
end
