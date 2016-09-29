Rails.application.routes.draw do

  scope module: 'api' do
    namespace :v1 do
      resources :wiki, only: [:index, :calendar] do
        #TODO: allow wiki/showname route
        collection do
          get '/calendar', to: 'wiki#calendar'
          get '/', to: 'wiki#index'
        end
      end
    end
  end
end
