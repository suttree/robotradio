class HomeController < ApplicationController
  def index
    # ugh
    #@files = Dir.entries(Rails.root + 'public/content/').reject{ |file| ['.', '..'].include? (file) }.collect{ |f| "/content/#{f}" }


    files =  Dir.entries(Rails.root + 'public/content/').select{ |x| x != '.' && x != '..' }.sort_by{ |f|File.mtime(Rails.root + 'public/content/' + f) }.reverse.collect{ |f| "/content/#{f}" }

    @files = []
    files.each do |file|
      Mp3Info.open(file) do |mp3|
        files << [file, mp3.tag.title]
      end
    end
  end

  def add
  end

  def save
    StoryWorker.perform_async(params[:q])

    flash[:notice] = 'Article added to queue'
    redirect_to root_path
  end
end
