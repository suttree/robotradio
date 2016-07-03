class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.string :title
      t.string :slug
      t.string :url
      t.string :filename
      t.string :image
      t.timestamps null: false
    end
  end
end
