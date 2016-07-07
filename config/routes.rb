Rails.application.routes.draw do

  scope module: 'api' do
    namespace :v1 do
      resources :wiki, only: [:index] do
        collection do
          get ':url', to: 'wiki#index'
        end
      end
    end
  end
end
