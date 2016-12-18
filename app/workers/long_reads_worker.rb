require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

class LongReadsWorker
  def self.create
    probability = 3
    if (rand(4) > probability)
      puts "Searching with longreads 1"
      doc = Nokogiri::HTML(open('http://www.theatlantic.com/category/longreads/', :allow_redirections => :safe))
      links = doc.css('div.body a[data-omni-click]')
      link = links[rand(links.length)].attributes['href'].to_s

      if link.present?
        link = 'http://www.theatlantic.com' + link
        StoryWorker.create(link)
      end
    elsif (rand(8) > probability)
      puts "Searching with longreads 2"
      doc = Nokogiri::HTML(open('https://longreads.com/articles/search/', :allow_redirections => :safe))
      links = doc.css('a.h-one.article-title')
      link = links[rand(links.length)].attributes['href'].to_s

      if link.present?
        StoryWorker.create(link)
      end
    else
      puts "Searching with longreads 3"
      doc = Nokogiri::HTML(open('http://www.newstatesman.com/long-reads', :allow_redirections => :safe))
      links = doc.css('ul.article-list h2 a')
      link = links[rand(links.length)].attributes['href'].to_s

      if link.present?
        link = 'http://www.newstatesman.com' + link
        StoryWorker.create(link)
      end
    end
  end
end
