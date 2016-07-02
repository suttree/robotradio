namespace :content do
  desc "Scrape links from amyhref.com and use them for stories"
  task :amy => :environment do
    AmyWorker.create
  end
end
