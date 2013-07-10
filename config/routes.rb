GhcrWeb::Application.routes.draw do
  scope "/api/v1/:owner/:repo" do
    resources :commits
  end
end
