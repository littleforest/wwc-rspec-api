# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API::V1::Sessions', type: :request do
  describe 'POST #create' do
    let(:path) { '/v1/sign_in' }
    let(:user) { create(:user) }

    context 'with valid params' do
      let(:valid_params) {
        {
          email: user.email,
          password: 'supersecret',
        }
      }

      it 'returns HTTP status success' do
        post path, params: valid_params
        expect(response).to have_http_status(:success)
      end

      it 'returns user info in response' do
        post path, params: valid_params
        expect(json['payload'].keys).to match_array(%w(id email auth_token username))
        expect(json['payload']['id']).to_not be nil
        expect(json['payload']['email']).to eq user.email
        expect(json['payload']['auth_token']).to_not be nil
      end
    end

    context 'with invalid password' do
      let(:invalid_params) {
        {
          email: user.email,
          password: 'badpassword',
        }
      }

      it 'returns HTTP 422 status' do
        post path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error info in response' do
        post path, params: invalid_params
        expect(json['error']).to eq 'Invalid email or password'
      end
    end

    context 'with invalid email' do
      let(:invalid_params) {
        {
          email: 'foo@example.com',
          password: 'supersecret',
        }
      }

      it 'returns HTTP 422 status' do
        post path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error info in response' do
        post path, params: invalid_params
        expect(json['error']).to eq 'Invalid email or password'
      end
    end
  end
end
