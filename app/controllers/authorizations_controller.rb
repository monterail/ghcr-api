class AuthorizationsController < ApplicationController

  def create
    if auth_hash
      if redirect_uri = request.env['omniauth.params']['redirect_uri'] || request.env['omniauth.origin']
        @user = User.find_or_create_by(email: auth_hash["info"]["email"]) do |u|
          u.name = auth_hash["info"]["name"]
          u.username = auth_hash["info"]["nickname"]
        end
        redirect_to URI(redirect_uri).tap { |u| u.fragment = "access_token=#{@user.access_token.token}&token_type=bearer" }.to_s
      else
        render json: { error: "No redirect_uri provided" }, status: 422
      end
    else
      render json: { error: "No auth info provided" }, status: 422
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
