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

  describe 'GET #show' do
    let(:recipe) { create(:recipe) }
    let(:path) { "/v1/recipes/#{recipe.id}" }

    shared_examples 'can view recipe' do
      it 'has success status' do
        get path, headers: auth_header(user)
        expect(response).to have_http_status(:success)
      end

      it 'returns recipe data' do
        get path, headers: auth_header(user)
        expect(json['payload'].keys).to match_array(%w(id title description))
        expect(json['payload']['id']).to eq recipe.id
        expect(json['payload']['title']).to eq recipe.title
        expect(json['payload']['description']).to eq recipe.description
      end
    end

    context 'when guest' do
      it_behaves_like 'can view recipe' do
        let(:user) { nil }
      end
    end

    context 'when recipe owner' do
      it_behaves_like 'can view recipe' do
        let(:user) { recipe.user }
      end
    end

    context 'when other user' do
      it_behaves_like 'can view recipe' do
        let(:user) { create(:user) }
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:recipe) { create(:recipe) }
    let(:path) { "/v1/recipes/#{recipe.id}" }

    shared_examples 'unauthorized' do
      it 'returns unauthorized' do
        delete path, headers: auth_header(user)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when guest' do
      it_behaves_like 'unauthorized' do
        let(:user) { nil }
      end
    end

    context 'when other user' do
      it_behaves_like 'unauthorized' do
        let(:user) { create(:user) }
      end
    end

    context 'when recipe owner' do
      let(:user) { recipe.user }

      context 'when destroy is successful' do
        it 'changes recipe count' do
          expect{
            delete path, headers: auth_header(user)
          }.to change(Recipe, :count).by(-1)
        end

        it 'returns http status success' do
          delete path, headers: auth_header(user)
          expect(response).to have_http_status(:success)
        end

        it 'returns recipe data' do
          delete path, headers: auth_header(user)
          expect(json['payload'].keys).to match_array(%w(id title description))
          expect(json['payload']['id']).to eq recipe.id
          expect(json['payload']['title']).to eq recipe.title
          expect(json['payload']['description']).to eq recipe.description
        end
      end

      context 'when destroy fails' do
        before do
          allow_any_instance_of(Recipe).to receive(:destroy).and_return(false)
        end

        it 'does not change recipe count' do
          expect{
            delete path, headers: auth_header(user)
          }.to_not change(Recipe, :count)
        end

        it 'has http status unprocessable entity' do
          delete path, headers: auth_header(user)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error message' do
          delete path, headers: auth_header(user)
          expect(json['error']).to_not be_blank
        end
      end
    end
  end

  describe '#like' do
    let(:user) { create(:user) }
    let(:path) { "/v1/recipes/#{recipe.id}/like" }

    context 'when like does not already exist' do
      it 'increases recipe_action count' do
      end

      it 'returns http status success' do
      end
    end

    context 'when like already exists' do
      let!(:recipe_action) { create(:recipe_action, user: user, recipe: recipe) }

      it 'does not increases recipe_action count' do
      end

      it 'returns http status success' do
      end
    end
  end

  describe '#unlike' do
    let(:user) { create(:user) }
    let(:path) { "/v1/recipes/#{recipe.id}/like" }

    context 'when like exists' do
      let!(:recipe_action) { create(:recipe_action, user: user, recipe: recipe) }

      it 'decreases recipe_action count' do
      end

      it 'returns http status success' do
      end
    end

    context 'when like does not exists' do
      it 'does not increases recipe_action count' do
      end

      it 'returns http status success' do
      end
    end
  end

  describe '#favorites' do
    let(:user) { create(:user) }
    let(:path) { '/v1/recipes/favorites' }
    let!(:recipe_actions) { create_list(:recipe_action, 2, user: user) }

    it 'returns success' do
      get path, headers: auth_header(user)
      expect(response).to have_http_status(:success)
    end

    it 'returns unauthorized if bad authorization' do
      get path, headers: bad_auth_header
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns list of favorites ordered by most recently favorited' do
      get path, headers: auth_header(user)
      last_recipe = recipe_actions.last.recipe
      first_recipe = recipe_actions.first.recipe
      expect(json['payload'].count).to eq 2
      expect(json['payload'][0].keys).to match_array(%w(id title description))
      expect(json['payload'][0]['id']).to eq last_recipe.id
      expect(json['payload'][0]['title']).to eq last_recipe.title
      expect(json['payload'][0]['description']).to eq last_recipe.description
      expect(json['payload'][1]['id']).to eq first_recipe.id
      expect(json['payload'][1]['title']).to eq first_recipe.title
      expect(json['payload'][1]['description']).to eq first_recipe.description
    end
  end
end
