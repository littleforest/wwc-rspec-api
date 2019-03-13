require 'rails_helper'

RSpec.describe Recipe, type: :model do
  it "has a valid factory" do
    recipe = build(:recipe)
    expect(recipe.valid?).to be true
  end

  let(:user) { create(:user) }
  let!(:r1) { create(:recipe, title: 'Foo') }
  let!(:r2) { create(:recipe, user: user, title: 'Boo') }
  let!(:r3) { create(:recipe, title: 'Moo') }
  let!(:r4) { create(:recipe, user: user, title: 'Zoo') }

  describe ".retrieve_all" do
    context "when user is nil" do
      it "returns all recipes, ordered by most recently created" do
        expect(Recipe.retrieve_all).to eq [r4, r3, r2, r1]
      end
    end

    context "when user is not nil" do
      it "returns all recipes not created by user, ordered by most recently created" do
        expect(Recipe.retrieve_all(user)).to contain_exactly(r3, r1)
        expect(Recipe.retrieve_all(user)).to match_array([r3, r1])
      end
    end
  end

  describe ".search" do
    it "returns all records if query parameter is blank" do
      expect(Recipe.search("")).to match_array([r4,r3,r2,r1])
      expect(Recipe.search(nil)).to match_array([r4,r3,r2,r1])
    end

    it "returns records the match title of query param" do
      expect(Recipe.search('Zoo')).to eq [r4]
    end

    it "returns empty array if no match" do
      expect(Recipe.search('Too')).to eq []
      expect(Recipe.search('Too')).to be_empty
    end
  end
end
