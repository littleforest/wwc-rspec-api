require 'rails_helper'

RSpec.describe API::V1::AddToMailingList, type: :request do
  let(:user) { create(:user) }
  let(:service) { API::V1::AddToMailingList.new(user) }

  context 'when successful' do
    it 'returns true' do
      VCR.use_cassette("mailing_list_success") do
        expect(service.call).to be true
      end
    end
  end

  context 'when not successful' do
    it 'returns false' do
      VCR.use_cassette("mailing_list_failure") do
        expect(service.call).to be false
      end
    end
  end
end
