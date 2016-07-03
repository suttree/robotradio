Rails.application.routes.draw do
  root 'home#index'
  match '/shows/:slug', :to => 'shows#show', :via => :get
  match '/add', :to => 'home#add', :via => :get
  match '/save' ,:to => 'home#save', :via => :post
  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  match '/(:page)', :to => 'home#index', :via => :get
end
