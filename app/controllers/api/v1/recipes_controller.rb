# frozen_string_literal: true

class API::V1::RecipesController < API::V1::APIController
  before_action :optionally_authenticate

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
end
