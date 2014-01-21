module OmniauthMacros
  def mock_auth_hash
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      provider: 'github',
      uid: '1234561',
      info: {
        name: 'Dariusz Gertych',
        email: 'dariusz.gertych@gmail.com',
        nickname: 'chytreg'
      },
      credentials: {
        token: 'access-token'
      }
    })
  end
end
