# frozen_string_literal: true

class API::V1::RecipesController < API::V1::APIController
  before_action :optionally_authenticate, only: [:community]
  before_action :authenticate, except: [:community]

  def create
    @recipe = current_user.recipes.build(recipe_params)
    if @recipe.save
      render json: @recipe, root: API_ROOT
    else
      render json: { error: @recipe.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  def community
    if params[:q].present? && current_user.nil?
      @recipes = Recipe.where(title: params[:q]).order(id: :desc)
      render json: @recipes, root: API_ROOT
    elsif params[:q].present? && current_user.present?
      @recipes = Recipe.where(title: params[:q])
                       .where.not(user: current_user).order(id: :desc)
      render json: @recipes, root: API_ROOT
    elsif current_user
      @recipes = Recipe.where.not(user_id: current_user.id).order(id: :desc)
      render json: @recipes, root: API_ROOT
    else
      @recipes = Recipe.order(id: :desc)
      render json: @recipes, root: API_ROOT
    end
  end

  private

  def recipe_params
    params.permit(:title, :description)
  end
end
