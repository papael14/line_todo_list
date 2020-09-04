Rails.application.routes.draw do
  post "/callback" => "line_bot#callback"
  get 'line_bot/callback'
  get 'callback/index'
  #resources :callback
  resources :tasks
  get 'homes/index'
#  root "tasks#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
