require 'spec_helper'

describe AuthorizationsController do
  describe 'GET #create' do
    context "empty auth_hash" do
      it 'should render error json' do
        get :create, default: { provider: 'github' }
        expect(response.status).to eq(422)
        expect(response.body).to have_json_path('error')
      end
    end

    context "empty redirect_uri" do
      before { request.env['omniauth.auth'] = mock_auth_hash }

      it 'should render error json' do
        get :create, default: { provider: 'github' }
        expect(response.status).to eq(422)
        expect(response.body).to have_json_path('error')
        expect(parse_json(response.body)['error']).to include('redirect_uri')
      end
    end

    context "success authorization" do
      let(:redirect_uri) { "http://redirect-example.com" }
      let(:user) { User.find_by(username: 'chytreg') }
      before do
        request.env['omniauth.auth'] = mock_auth_hash
        request.env['omniauth.params'] = {'redirect_uri' => redirect_uri, 'origin' => redirect_uri}
      end

      it "should save data and redirect" do
        expect {
          get :create, default: { provider: 'github' }
        }.to change{User.count}.by(1)
        expect(user).to be_present
        expect(user.access_token).to be_present
        expect(response.status).to eq(302)
        expect(response).to redirect_to("#{redirect_uri}#access_token=#{user.access_token.token}&token_type=bearer")
      end

    end
  end
end
