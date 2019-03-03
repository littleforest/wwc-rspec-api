# frozen_string_literal: true

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
      get path, headers: auth_header(user)
      expect(json['payload'].keys).to match_array(%w(id email auth_token username))
      expect(json['payload']['id']).to eq user.id
      expect(json['payload']['email']).to eq user.email
      expect(json['payload']['auth_token']).to eq user.auth_token
      expect(json['payload']['username']).to be nil
    end
  end

  describe 'PATCH #me' do
    shared_examples 'unauthorized' do
      it 'returns unauthorized if bad authorization' do
        patch path, params: params, headers: bad_auth_header
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with valid params' do
      let(:params) {
        {
          email: 'foobar@example.com',
          username: 'foobar'
        }
      }

      it 'returns success if authorized' do
        patch path, params: params, headers: auth_header(user)
        expect(response).to have_http_status(:success)
      end

      it_behaves_like 'unauthorized'

      it 'updates user' do
        patch path, params: params, headers: auth_header(user)
        user.reload
        expect(user.email).to eq 'foobar@example.com'
        expect(user.username).to eq 'foobar'
      end

      it 'returns user info in response' do
        patch path, params: params, headers: auth_header(user)
        expect(json['payload'].keys).to match_array(%w(id email auth_token username))
        expect(json['payload']['id']).to eq user.id
        expect(json['payload']['email']).to eq 'foobar@example.com'
        expect(json['payload']['auth_token']).to eq user.auth_token
        expect(json['payload']['username']).to eq 'foobar'
      end
    end

    context 'with invalid params' do
      let(:params) {
        {
          email: '',
          username: 'foobar'
        }
      }

      it_behaves_like 'unauthorized'

      it 'returns HTTP 422 status' do
        patch path, params: params, headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update user' do
        patch path, params: params, headers: auth_header(user)
        user.reload
        expect(user.email).to_not be_blank
        expect(user.username).to be nil
      end

      it 'returns error info in response' do
        patch path, params: params, headers: auth_header(user)
        expect(json['error']).to eq "Email can't be blank"
      end
    end
  end
end
