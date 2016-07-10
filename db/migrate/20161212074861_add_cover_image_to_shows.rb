class AddCoverImageToShows < ActiveRecord::Migration
  def change
    add_attachment :shows, :cover_image
  end
end
