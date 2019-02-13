require 'rails_helper'

RSpec.describe 'API::V1::Profile', type: :request do
  let(:user) { create(:user) }
  let(:path) { '/v1/me' }

  describe 'GET #me' do
    it 'returns success if authorized' do
      get path, headers: auth_header(user)
      expect(response).to have_http_status(:success)
    end

    it 'returns unauthorized if bad authorization' do
      get path, headers: bad_auth_header
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns user info in response' do
    end
  end

  describe 'PATCH #me' do
    shared_examples 'authorization' do
      it 'returns success if authorized' do
        patch path, params: params, headers: auth_header(user)
        expect(response).to have_http_status(:success)
      end

      it 'returns unauthorized if bad authorization' do
        patch path, params: params, headers: bad_auth_header
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with valid params' do
      let(:params) {}

      it_behaves_like 'authorization' do
      end

      it 'updates user' do

      end

      it 'returns user info in response' do
      end
    end

    context 'with invalid params' do
      let(:params) {}

      it_behaves_like 'authorization'

      it 'returns HTTP 422 status' do
      end

      it 'does not update user' do
      end

      it 'returns error info in response' do
      end
    end
  end
end
