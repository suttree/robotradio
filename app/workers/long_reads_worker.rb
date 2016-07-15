require 'nokogiri'
require 'open-uri'

class LongReadsWorker
  def self.create
    puts "Searching with longreads 1"
    doc = Nokogiri::HTML(open('http://www.theatlantic.com/category/longreads/'))
    links = doc.css('div.body a[data-omni-click]')
    link = links[rand(links.length)].attributes['href'].to_s

    if link.present?
      link = 'http://www.theatlantic.com' + link
      StoryWorker.delay.create(link)
    end

    puts "Searching with longreads 2"
    doc = Nokogiri::HTML(open('http://www.newstatesman.com/long-reads'))
    links = doc.css('ul.article-list h2 a')
    link = links[rand(links.length)].attributes['href'].to_s

    if link.present?
      link = 'http://www.newstatesman.com' + link
      StoryWorker.delay.create(link)
    end
  end
end
