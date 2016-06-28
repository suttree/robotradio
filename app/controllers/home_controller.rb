class HomeController < ApplicationController
  def index
    # ugh
    @files = Dir.entries(Rails.root + 'public/content/').reject{ |file| ['.', '..'].include? (file) }.collect{ |f| "/content/#{f}" }
  end

  def add
  end

  def save
    %x[rake story:create URL=#{params[:q]}]

    flash[:notice] = 'Article added'
    redirect_to root_path
  end
end
