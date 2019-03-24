require 'rails_helper'

RSpec.describe API::V1::AddToMailingList, type: :request do
  let(:user) { create(:user) }
  let(:service) { API::V1::AddToMailingList.new(user) }

  context 'when successful' do
    before { mailchimp_add_member_success }

    it 'returns true' do
      expect(service.call).to be true
    end
  end

  context 'when not successful' do
    before { mailchimp_add_member_failure }

    it 'returns false' do
      expect(service.call).to be false
    end
  end
end
