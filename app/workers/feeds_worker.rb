require 'nokogiri'
require 'open-uri'
require 'feed-normalizer'

class FeedsWorker
  def self.create
    feeds = ['http://mentalfloss.com/uk/feeds/all', 'http://www.solidsmack.com/feed/']

    feeds.each do |url|
      puts "Searching with feeds - " + url

      feed = FeedNormalizer::FeedNormalizer.parse open(url, :allow_redirections => :safe)
      entry = feed.entries.sort_by{ rand }.first
      entry.clean! rescue nil

      doc = Nokogiri::HTML(open(entry, :allow_redirections => :safe))
      links = doc.css('a')
      link = links[rand(links.length)].attributes['href'].to_s
      StoryWorker.delay.create(link) if link
    end
  end
end
