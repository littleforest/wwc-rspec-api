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

  describe "POST #create" do
    let(:path) { '/v1/recipes' }
    let(:user) { create(:user) }

    context 'with valid params' do
      let(:valid_params) {
        {
          title: 'Spaghetti',
          description: 'a'*1000,
        }
      }

      it 'returns success' do
        post path, params: valid_params, headers: auth_header(user)
        expect(response).to have_http_status(:success)
      end

      it 'returns unauthorized if bad authorization' do
        post path, params: valid_params, headers: bad_auth_header
        expect(response).to have_http_status(:unauthorized)
      end

      it 'increases recipe count' do
        expect {
          post path, params: valid_params, headers: auth_header(user)
        }.to change(user.recipes, :count).by(1)
      end

      it 'returns recipe info in response' do
        post path, params: valid_params, headers: auth_header(user)
        expect(json['payload'].keys).to match_array(%w(id title description))
        expect(json['payload']['id']).to_not be nil
        expect(json['payload']['title']).to eq 'Spaghetti'
        expect(json['payload']['description']).to eq 'a'*1000
      end
    end

    context 'with invalid params' do
      let(:invalid_params) {
        {
          title: '',
          description: 'a'*1000,
        }
      }

      it 'does not increase recipe count' do
        expect {
          post path, params: invalid_params, headers: auth_header(user)
        }.to_not change(Recipe, :count)
      end

      it 'returns HTTP 422 status' do
        post path, params: invalid_params, headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error info in response' do
        post path, params: invalid_params, headers: auth_header(user)
        expect(json['error']).to eq "Title can't be blank"
      end
    end
  end

  describe 'PATCH #update' do
    let(:recipe) { create(:recipe) }
    let(:path) { "/v1/recipes/#{recipe.id}" }
    let(:user) { create(:user) }

    let(:valid_params) {
      {
        title: 'Spaghetti',
        description: 'a'*1000,
      }
    }

    shared_examples 'unauthorized' do
      it 'returns unauthorized' do
        patch path, params: valid_params, headers: auth_header(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when guest' do
      it_behaves_like 'unauthorized' do
        let(:user) { nil }
      end
    end

    context 'when non-recipe owner' do
      it_behaves_like 'unauthorized'
    end

    context 'when recipe owner' do
      let!(:recipe) { create(:recipe, user: user) }

      context 'with valid params' do
        it 'returns success' do
          patch path, params: valid_params, headers: auth_header(user)
          expect(response).to have_http_status(:success)
        end

        it 'returns unauthorized if bad authorization' do
          patch path, params: valid_params, headers: bad_auth_header
          expect(response).to have_http_status(:unauthorized)
        end

        it 'does not increase recipe count' do
          expect {
            patch path, params: valid_params, headers: auth_header(user)
          }.to_not change(Recipe, :count)
        end

        it 'returns recipe info in response' do
          patch path, params: valid_params, headers: auth_header(user)
          expect(json['payload'].keys).to match_array(%w(id title description))
          expect(json['payload']['id']).to eq recipe.id
          expect(json['payload']['title']).to eq 'Spaghetti'
          expect(json['payload']['description']).to eq 'a'*1000
        end
      end

      context 'with invalid params' do
        let(:invalid_params) {
          {
            title: '',
            description: 'a'*1000,
          }
        }

        it 'returns HTTP 422 status' do
          patch path, params: invalid_params, headers: auth_header(user)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error info in response' do
          patch path, params: invalid_params, headers: auth_header(user)
          expect(json['error']).to eq "Title can't be blank"
        end
      end
    end
  end

  describe 'GET #index' do
    let(:path) { '/v1/recipes' }

    shared_examples 'unauthorized' do
      it 'returns unauthorized' do
        get path, headers: auth_header(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'guest' do
      it_behaves_like 'unauthorized' do
        let(:user) { nil }
      end
    end

    context 'user' do
      let(:user) { create(:user) }
      let!(:recipes) { create_list(:recipe, 2, user: user) }
      let!(:other_recipe) { create(:recipe) }

      it 'has http status success' do
        get path, headers: auth_header(user)
        expect(response).to have_http_status(:success)
      end

      it 'returns recipe list, most recently created' do
        get path, headers: auth_header(user)
        expect(json['payload'].count).to eq 2
        expect(json['payload'][0].keys).to match_array(%w(id title description))
        expect(json['payload'][0]['id']).to eq recipes.last.id
        expect(json['payload'][0]['title']).to eq recipes.last.title
        expect(json['payload'][0]['description']).to eq recipes.last.description
        expect(json['payload'][1]['id']).to eq recipes.first.id
        expect(json['payload'][1]['title']).to eq recipes.first.title
        expect(json['payload'][1]['description']).to eq recipes.first.description
      end
    end
  end
end
