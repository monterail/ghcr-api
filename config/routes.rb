GhcrWeb::Application.routes.draw do
  get "/authorize", to: 'authorizations#new'

  post "/api/v1/github", :to => "github#payload"

  scope "/api/v1/:owner/:repo" do
    resources :commits
  end

  resource :stats, :only => :show
end
