require 'rails_helper'

RSpec.describe Recipe, type: :model do
  it "has a valid factory" do
    recipe = build(:recipe)
    expect(recipe.valid?).to be true
  end

  describe ".retrieve_all" do
    context "when user is nil" do
      it "returns all recipes, ordered by most recently created" do
      end
    end

    context "when user is not nil" do
      it "returns all recipes not created by user, ordered by most recently created" do
      end
    end
  end
end
