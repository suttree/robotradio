require 'mp3info'

class HomeController < ApplicationController
  def index
    # ugh
    #@files = Dir.entries(Rails.root + 'public/content/').reject{ |file| ['.', '..'].include? (file) }.collect{ |f| "/content/#{f}" }


    files =  Dir.entries(Rails.root.to_s + '/public/content/').select{ |x| x != '.' && x != '..' }.sort_by{ |f|File.mtime(Rails.root + 'public/content/' + f) }.reverse.collect{ |f| "/content/#{f}" }[0..4]

    @files = []
    files.flatten.each do |file|
      puts file.inspect
      Mp3Info.open(Rails.root.to_s + '/public' + file) do |mp3|
        @files << [file, mp3.tag.title]
      end
    end
  end

  def add
  end

  def save
    StoryWorker.delay.create(params[:q])

    flash[:notice] = 'Article added to queue'
    redirect_to root_path
  end
end
