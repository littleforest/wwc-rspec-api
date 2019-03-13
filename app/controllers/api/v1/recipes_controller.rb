# frozen_string_literal: true

class API::V1::RecipesController < API::V1::APIController
  before_action :optionally_authenticate, only: [:community]
  before_action :authenticate, except: [:community]

  before_action :set_recipe, only: [:update]

  def index
    @recipes = Recipe.all.order(id: :desc)
    render json: @recipes, root: API_ROOT
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)
    if @recipe.save
      render json: @recipe, root: API_ROOT
    else
      render json: { error: @recipe.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      render json: @recipe, root: API_ROOT
    else
      render json: { error: @recipe.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  def community
    if params[:q].present?
      @recipes = Recipe.retrieve_all(current_user).where(title: params[:q])
    else
      @recipes = Recipe.retrieve_all(current_user)
    end
    render json: @recipes, root: API_ROOT
  end

  private

  def recipe_params
    params.permit(:title, :description)
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end
end
