class ApplicationController < ActionController::API
  def current_token
    request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
  end

  def authenticate!
    return true if Rails.env.development? && params[:username].present?
    current_token or raise Rack::OAuth2::Server::Resource::Bearer::Unauthorized
  end

  def current_user
    if Rails.env.development? && params[:username].present?
      User.find_by!(username: params[:username])
    else
      current_token && current_token.user
    end
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end
end
