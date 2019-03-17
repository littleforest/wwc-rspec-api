require 'rails_helper'

RSpec.describe RecipeAction, type: :model do
  it 'has a valid factory' do
    recipe_action = build(:recipe_action)
    expect(recipe_action.valid?).to be true
  end
end
