Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health", to: proc {
        [
          200,
          { 'Content-Type' => 'application/json' },
          [ { message: "Everything is good👌" }.to_json ]
        ]
      }
      resources :flights, only: [ :index ] do
        collection do
          get :details
          get :search
          patch :update_seat_count
        end
      end
    end
  end
end
