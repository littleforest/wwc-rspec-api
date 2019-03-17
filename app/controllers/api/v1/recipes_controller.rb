# frozen_string_literal: true

class API::V1::RecipesController < API::V1::APIController
  before_action :optionally_authenticate, only: [:show, :community]
  before_action :authenticate, except: [:show, :community]

  before_action :set_recipe, only: [:show, :update, :destroy]

  def index
    @recipes = current_user.recipes.order(id: :desc)
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

  def show
    render json: @recipe, root: API_ROOT
  end

  def update
    authorize @recipe
    if @recipe.update(recipe_params)
      render json: @recipe, root: API_ROOT
    else
      render json: { error: @recipe.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  def destroy
    authorize @recipe
    if @recipe.destroy
      render json: @recipe, root: API_ROOT
    else
      render json: { error: @recipe.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  def community
    @recipes = Recipe.search(params[:q]).retrieve_all(current_user)
    render json: @recipes, root: API_ROOT
  end

  def like
  end

  def unlike
  end

  private

  def recipe_params
    params.permit(:title, :description)
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end
end
