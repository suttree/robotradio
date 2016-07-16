namespace :content do
  desc "Scrape links from amyhref.com and use them for stories"
  task :amy => :environment do
    AmyWorker.delay.create
  end

  task :tiny_assistant => :environment do
    TinyAssistantWorker.delay.create
  end

  task :daily_inspiration => :environment do
    DailyInspirationWorker.delay.create
  end

  task :longreads => :environment do
    LongReadsWorker.delay.create
  end

  task :feeds => :environment do
    FeedsWorker.delay.create
  end
end
