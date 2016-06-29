require 'sidekiq/web'

Rails.application.routes.draw do
  root 'home#index'
  match '/add', :to => 'home#add', :via => :get
  match '/save' ,:to => 'home#save', :via => :post

  mount Sidekiq::Web, at: "/sidekiq"
end
