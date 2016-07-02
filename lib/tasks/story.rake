#TODO be smarter when cleaning content - replace <p>, <i> and <b> with vocal/SSML tags
require 'open3'
require 'uri'
require 'open-uri'
require 'mp3info'
require 'soundcloud'

namespace :story do
  desc "Create a story from a url, run rake story:create URL=http://www.newyorker.com/books/joshua-rothman/what-are-the-odds-we-are-living-in-a-computer-simulation"
  task :create => :environment do
    StoryWorker.delay.create(ENV['URL'])
  end
end
