GhcrWeb::Application.routes.draw do
  get "/authorize", to: 'authorizations#new'

  scope "/api/v1/:owner/:repo" do
    resources :commits
  end

  resource :stats, :only => :show
end
