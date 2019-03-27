# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API::V1::Registrations', type: :request do
  describe 'POST #create' do
    let(:path) { '/v1/sign_up' }
    let(:service) { double("service", call: nil) }

    before do
      allow(API::V1::AddToMailingList).to receive(:new).and_return(service)
    end

    context 'with valid params' do
      let(:valid_params) {
        {
          email: 'foo@example.com',
          password: 'supersecret',
          password_confirmation: 'supersecret',
        }
      }

      it 'increases user count' do
        expect {
          post path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns HTTP status success' do
        post path, params: valid_params
        expect(response).to have_http_status(:success)
      end

      it 'returns user info in response' do
        post path, params: valid_params
        expect(json['payload'].keys).to match_array(%w(id email auth_token username))
        expect(json['payload']['id']).to_not be nil
        expect(json['payload']['email']).to eq 'foo@example.com'
        expect(json['payload']['auth_token']).to_not be nil
        expect(json['payload']['username']).to be nil
      end

      it 'calls the AddToMailingList service' do
        expect(API::V1::AddToMailingList).to receive(:new).and_return(service)
        expect(service).to receive(:call)
        post path, params: valid_params
      end
    end

    context 'with invalid params' do
      let(:invalid_params) {
        {
          email: 'foo@example.com',
          password: 'supersecret',
          password_confirmation: 'badmatch',
        }
      }

      it 'does not increase user count' do
        expect {
          post path, params: invalid_params
        }.to_not change(User, :count)
      end

      it 'returns HTTP 422 status' do
        post path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error info in response' do
        post path, params: invalid_params
        expect(json['error']).to eq "Password confirmation doesn't match Password"
      end

      it 'does not call the AddToMailingList service' do
        service = double("service", call: nil)
        expect(API::V1::AddToMailingList).to_not receive(:new)
        post path, params: invalid_params
      end
    end
  end
end
