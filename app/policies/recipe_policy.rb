class RecipePolicy
  attr_reader :user, :recipe

  def initialize(user, recipe)
    @user = user
    @recipe = recipe
  end

  def update?
    recipe.user == user
  end

  def destroy?
    update?
  end
end
