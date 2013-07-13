GhcrWeb::Application.routes.draw do
  scope "/api/v1/" do
    get '/authorize/callback', to: 'authorizations#create', default: { provider: 'github' }

    post '/github', to: "github#payload"

    scope ":owner/:repo" do
      resources :commits
      resource :reminder, only: [:show, :create, :update, :destroy]
    end

    resource :stats, only: :show
  end
end
