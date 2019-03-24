require 'rails_helper'

RSpec.describe API::V1::AddToMailingList, type: :request do
  let(:user) { create(:user) }
  let(:http) { double('http', post: resp) }
  let(:service) { API::V1::AddToMailingList.new(user) }

  before do
    allow(HTTP).to receive(:basic_auth).and_return(http)
    allow(http).to receive(:post).and_return(resp)
  end

  context 'when successful' do
    let(:resp) { double(:response, code: 200) }

    it 'calls HTTP gem' do
      expect(HTTP).to receive(:basic_auth).and_return(http)
      expect(http).to receive(:post).with(anything, json: { email_address: user.email, status: 'subscribed' })
      service.call
    end

    it 'returns true' do
      expect(service.call).to be true
    end
  end

  context 'when not successful' do
    let(:resp) { double(:response, code: 422) }

    it 'calls HTTP gem' do
      expect(HTTP).to receive(:basic_auth).and_return(http)
      expect(http).to receive(:post).with(anything, json: { email_address: user.email, status: 'subscribed' })
      service.call
    end

    it 'returns false' do
      expect(service.call).to be false
    end
  end
end
