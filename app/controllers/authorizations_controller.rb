class AuthorizationsController < ApplicationController

  def create
    unless auth_hash
      render(status: :unprocessable_entity, json: { error: 'No auth info provided' }) and return
    end
    if redirect_uri = request.env['omniauth.params']['redirect_uri'] || request.env['omniauth.origin']
      user = User.find_or_create_by(:username, auth_hash['info']['nickname']) do |u|
        u.name  = auth_hash['info']['name']
        u.email = auth_hash['info']['email']
        u.github_access_token = auth_hash['credentials']['token']
        u.save! if u.changed?
      end

      redirect_to URI(redirect_uri).tap { |url|
        url.fragment = 'access_token=#{user.access_token.token}&token_type=bearer'
      }.to_s
    else
      render status: :unprocessable_entity, json: { error: 'No redirect_uri provided' }
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end
