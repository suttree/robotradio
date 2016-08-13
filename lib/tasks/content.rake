namespace :content do
  desc "Scrape links from amyhref.com and use them for stories"
  task :amy => :environment do
    AmyWorker.create
  end

  task :tiny_assistant => :environment do
    TinyAssistantWorker.create
  end

  task :daily_inspiration => :environment do
    DailyInspirationWorker.create
  end

  task :longreads => :environment do
    LongReadsWorker.create
  end

  task :feeds => :environment do
    FeedsWorker.create
  end
end
