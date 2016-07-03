class ShowsController < ApplicationController
  def show
    @show = Show.where(:slug => params[:slug]).first
  end
end
