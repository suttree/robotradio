class Show < ActiveRecord::Base
  validates :slug, uniqueness: true
end
