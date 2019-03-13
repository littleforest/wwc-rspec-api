class RecipePolicy
  attr_reader :user, :recipe

  def initialize(user, recipe)
    @user = user
    @recipe = recipe
  end

  def update?
    recipe.user == user
  end
end
