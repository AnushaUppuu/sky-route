Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
   root "flights#index"
  resources :flights, only: [ :index ] do
    collection do
      get :details
      get :search
      get :update_seat_count
    end
  end
end
