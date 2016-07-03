require 'mp3info'

class HomeController < ApplicationController
  def index
    @shows = Show.order('created_at DESC').paginate(:page => params[:page])
  end

  def add
  end

  def save
    StoryWorker.delay.create(params[:q])

    flash[:notice] = 'Article added to queue'
    redirect_to root_path
  end
end
