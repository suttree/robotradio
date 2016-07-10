class Show < ActiveRecord::Base
  has_attached_file :cover_image, styles: { large: '600x300>', medium: '300x300>', thumb: '100x100>' }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\Z/
  validates :slug, uniqueness: true
end
