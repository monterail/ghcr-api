require 'spec_helper'

describe GithubController do
  describe 'POST payload' do
    it 'should receive sample payload' do
      payload = File.read(
        File.join(File.dirname(__FILE__), '../fixtures/test_payload.json'))

      post :payload, payload: payload, format: :json
      
      expect(response.status).to eq(200)
    end
  end
end
