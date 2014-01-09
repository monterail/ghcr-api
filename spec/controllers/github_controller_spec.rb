require 'spec_helper'

describe GithubController do
  describe 'POST payload' do
    it 'should add new commits' do
      pending "This test needs to be updated!"

      payload = fixture('test_payload.json')

      expect {
        post :payload, payload: payload, format: :json
      }.to change { Commit.count }.by(3)

      Commit.all.all? { |c| c.status.should == 'pending' }

      expect(response.status).to eq(200)
    end
  end
end
