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

      resources :flights, only: [] do
        collection do
          post :search, to: "flights#search"
        end
      end

      resources :cities, only: [ :index ]
      resources :airports, only: [ :index ]
      post "flight_schedules/search", to: "flight_schedules#search"
      post "flight_seats/update_count", to: "flight_seats#update_count"
    end
  end
end
