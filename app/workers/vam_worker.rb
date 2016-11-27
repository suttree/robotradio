require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

class VamWorker
  def self.create
    puts "Searching with V&A"
    doc = Nokogiri::HTML(open('http://www.vam.ac.uk/blog', :allow_redirections => :safe))
    links = doc.css('div.recent_posts_wdgt ul li')
    link = links[rand(links.length)].attributes['href'].to_s
    link = links[rand(links.length)].children[1].attributes['href'].to_s
    #links[1].children[1].attributes['href']
puts link.inspect
puts "----"

    if link.present?
puts link.inspect
puts "%%%%%"
      StoryWorker.create(link)
    end
  end
end
