class AddDurationToShows < ActiveRecord::Migration
  def change
    add_column :shows, :duration, :float
  end
end
