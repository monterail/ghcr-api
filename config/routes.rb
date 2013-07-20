GhcrWeb::Application.routes.draw do
  scope "/api/v1/" do
    get '/authorize/callback', to: 'authorizations#create', default: { provider: 'github' }

    post '/github', to: "github#payload"

    scope ":owner/:repo" do
      resources :commits do
        collection do
          get :count
        end
      end
      resource :reminder, only: [:show, :create, :update, :destroy]

      get '/', to: "github#show"
    end

    resource :stats, only: :show
  end
end
