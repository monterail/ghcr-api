GhcrApi::Application.routes.draw do
  scope "/api/v1/" do
    get '/authorize/callback', to: 'authorizations#create', default: { provider: 'github' }

    post '/github/:repository_token', to: "github#payload"

    get '/init', to: 'users#show'
    put '/settings', to: "users#update"
    resource :stats, only: :show do
      collection do
        get :commits
      end
    end
    scope ":owner/:repo", constraints: { repo: /[^\/]+/ } do
      resources :commits do
        collection do
          get :count
          get :next
        end
        member do
          get :next
        end
      end
      resource :reminder, only: [:show, :create, :update, :destroy]

      get '/', to: "github#show"
      post '/connect', to: "github#connect"
    end
  end
end
