require 'spec_helper'

describe GithubController do
  describe 'POST payload' do
    let(:repository) { Repository.create(name: 'test', owner: 'chytreg') }

    it 'should add new commits' do
      payload = fixture('test_payload.json')

      expect {
        post :payload, { payload: payload, repository_token: repository.access_token, format: :json }
      }.to change { Commit.count }.by(3)

      Commit.all.all? { |c| c.status.should == 'pending' }

      expect(response.status).to eq(200)
    end
  end
end
