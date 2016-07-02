namespace :content do
  desc "Scrape links from amyhref.com and use them for stories"
  task :amy => :environment do
    AmyWorker.delay.create
  end
end
