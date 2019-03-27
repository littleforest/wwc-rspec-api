require 'rails_helper'

RSpec.describe API::V1::AddToMailingList, type: :request do
  let(:user) { create(:user) }
  let(:service) { API::V1::AddToMailingList.new(user) }

  context 'when successful' do
#    before { mailchimp_add_member_success }
    before { more_complicated_example_success(user.email) }

    it 'returns true' do
      expect(service.call).to be true
    end

    it 'assigns returned mailchimp id to username field' do
      service.call
      user.reload
      expect(user.username).to eq 'some_mailchimp_id'
    end
  end

  context 'when not successful' do
#    before { mailchimp_add_member_failure }
    before { more_complicated_example_failure(user.email) }

    it 'returns false' do
      expect(service.call).to be false
    end
  end
end
