Rails.application.routes.draw do

  scope module: 'api' do
    namespace :v1 do
      resources :wiki, only: [:index] do
        #TODO: allow wiki/showname route
        collection do
          get '/', to: 'wiki#index'
        end
      end
      get '/:title/calendar.ics', to: 'calendar#show', :constraints => { :title => /[^\/]+/ }
      get '/recent', to: 'calendar#recent'
    end
  end
end
