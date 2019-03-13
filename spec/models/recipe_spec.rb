require 'rails_helper'

RSpec.describe Recipe, type: :model do
  it "has a valid factory" do
    recipe = build(:recipe)
    expect(recipe.valid?).to be true
  end

  describe ".retrieve_all" do
    let(:user) { create(:user) }
    let!(:r1) { create(:recipe) }
    let!(:r2) { create(:recipe, user: user) }
    let!(:r3) { create(:recipe) }
    let!(:r4) { create(:recipe, user: user) }

    context "when user is nil" do
      it "returns all recipes, ordered by most recently created" do
        expect(Recipe.retrieve_all).to eq [r4, r3, r2, r1]
      end
    end

    context "when user is not nil" do
      it "returns all recipes not created by user, ordered by most recently created" do
        expect(Recipe.retrieve_all(user)).to eq [r3, r1]
      end
    end
  end
end
