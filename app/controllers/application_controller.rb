class ApplicationController < ActionController::API
  def current_token
    request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
  end

  def authenticate!
    current_token or raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized
  end

  def current_user
    current_token && current_token.user
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end
end
