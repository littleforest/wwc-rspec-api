# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API::V1::Recipes', type: :request do

  describe 'GET #community' do
    let(:path) { '/v1/recipes/community' }
    let(:some_user) { create(:user) }

    let!(:r1) { create(:recipe, title: 'Foo') }
    let!(:r2) { create(:recipe, title: 'Boo', user: some_user) }
    let!(:r3) { create(:recipe, title: 'Moo') }
    let!(:r4) { create(:recipe, title: 'Zoo', user: some_user) }

    shared_examples "success response" do
      it 'returns success' do
        get path, headers: auth_header(user)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when guest' do
      let(:user) { nil }

      it_behaves_like 'success response'

      context "without search" do
        it 'returns all recipes, most recent first' do
          get path, headers: auth_header(user)
          expect(json['payload'].count).to eq 4
          expect(json['payload'][0].keys).to match_array(%w(id title description))
          expect(json['payload'][0]['id']).to eq r4.id
          expect(json['payload'][0]['title']).to eq 'Zoo'
          expect(json['payload'][0]['description']).to eq r4.description
          expect(json['payload'][1]['id']).to eq r3.id
          expect(json['payload'][1]['title']).to eq 'Moo'
          expect(json['payload'][1]['description']).to eq r3.description
          expect(json['payload'][2]['id']).to eq r2.id
          expect(json['payload'][2]['title']).to eq 'Boo'
          expect(json['payload'][2]['description']).to eq r2.description
          expect(json['payload'][3]['id']).to eq r1.id
          expect(json['payload'][3]['title']).to eq 'Foo'
          expect(json['payload'][3]['description']).to eq r1.description
        end
      end

      context 'with search' do
        context 'when search term is blank' do
          let(:path) { '/v1/recipes/community?q=' }

          it 'returns all recipes' do
            get path, headers: auth_header(user)
            expect(json['payload'].count).to eq 4
            expect(json['payload'][0].keys).to match_array(%w(id title description))
            expect(json['payload'][0]['id']).to eq r4.id
            expect(json['payload'][0]['title']).to eq 'Zoo'
            expect(json['payload'][0]['description']).to eq r4.description
            expect(json['payload'][1]['id']).to eq r3.id
            expect(json['payload'][1]['title']).to eq 'Moo'
            expect(json['payload'][1]['description']).to eq r3.description
            expect(json['payload'][2]['id']).to eq r2.id
            expect(json['payload'][2]['title']).to eq 'Boo'
            expect(json['payload'][2]['description']).to eq r2.description
            expect(json['payload'][3]['id']).to eq r1.id
            expect(json['payload'][3]['title']).to eq 'Foo'
            expect(json['payload'][3]['description']).to eq r1.description
          end
        end

        context 'when search term matches result' do
          let(:path) { '/v1/recipes/community?q=Moo' }

          it 'returns matching recipe' do
            get path, headers: auth_header(user)
            expect(json['payload'].count).to eq 1
            expect(json['payload'][0].keys).to match_array(%w(id title description))
            expect(json['payload'][0]['id']).to eq r3.id
            expect(json['payload'][0]['title']).to eq 'Moo'
            expect(json['payload'][0]['description']).to eq r3.description
          end
        end

        context 'when search term does not match result' do
          let(:path) { '/v1/recipes/community?q=Too' }

          it 'returns empty array' do
            get path, headers: auth_header(user)
            expect(json['payload'].count).to eq 0
            expect(json['payload']).to be_a(Array)
          end
        end
      end
    end

    context 'when authorized user' do
      let(:user) { some_user }

      it_behaves_like 'success response'

      context "without search" do
        it 'returns recipes by other users, most recent first' do
          get path, headers: auth_header(user)
          expect(json['payload'].count).to eq 2
          expect(json['payload'][0].keys).to match_array(%w(id title description))
          expect(json['payload'][0]['id']).to eq r3.id
          expect(json['payload'][0]['title']).to eq 'Moo'
          expect(json['payload'][0]['description']).to eq r3.description
          expect(json['payload'][1]['id']).to eq r1.id
          expect(json['payload'][1]['title']).to eq 'Foo'
          expect(json['payload'][1]['description']).to eq r1.description
        end
      end

      context 'with search' do
        context 'when search term is blank' do
          let(:path) { '/v1/recipes/community?q=' }

          it 'returns recipes by other users' do
            get path, headers: auth_header(user)
            expect(json['payload'].count).to eq 2
            expect(json['payload'][0].keys).to match_array(%w(id title description))
            expect(json['payload'][0]['id']).to eq r3.id
            expect(json['payload'][0]['title']).to eq 'Moo'
            expect(json['payload'][0]['description']).to eq r3.description
            expect(json['payload'][1]['id']).to eq r1.id
            expect(json['payload'][1]['title']).to eq 'Foo'
            expect(json['payload'][1]['description']).to eq r1.description
          end
        end

        context 'when search term matches result of other user' do
          let(:path) { '/v1/recipes/community?q=Moo' }

          it 'returns matching recipe' do
            get path, headers: auth_header(user)
            expect(json['payload'].count).to eq 1
            expect(json['payload'][0].keys).to match_array(%w(id title description))
            expect(json['payload'][0]['id']).to eq r3.id
            expect(json['payload'][0]['title']).to eq 'Moo'
            expect(json['payload'][0]['description']).to eq r3.description
          end
        end

        context 'when search term matches result of authorized user' do
          let(:path) { '/v1/recipes/community?q=Zoo' }

          it 'returns empty array' do
            get path, headers: auth_header(user)
            expect(json['payload'].count).to eq 0
            expect(json['payload']).to be_a(Array)
          end
        end

        context 'when search term does not match result' do
          let(:path) { '/v1/recipes/community?q=Too' }

          it 'returns empty array' do
            get path, headers: auth_header(user)
            expect(json['payload'].count).to eq 0
            expect(json['payload']).to be_a(Array)
          end
        end
      end
    end
  end
end
