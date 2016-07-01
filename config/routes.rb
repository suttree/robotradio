Rails.application.routes.draw do
  root 'home#index'
  match '/add', :to => 'home#add', :via => :get
  match '/save' ,:to => 'home#save', :via => :post
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]
end
