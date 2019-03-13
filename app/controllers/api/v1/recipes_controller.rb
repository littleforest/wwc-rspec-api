# frozen_string_literal: true

class API::V1::RecipesController < API::V1::APIController
  before_action :authenticate_token

  def community
    if params[:q].present? && current_user.nil?
      @recipes = Recipe.where(title: params[:q]).order(id: :desc)
    elsif params[:q].present? && current_user.present?
      @recipes = Recipe.where(title: params[:q])
                       .where.not(user: current_user).order(id: :desc)
    elsif current_user
      @recipes = Recipe.where.not(user_id: current_user.id).order(id: :desc)
    else
      @recipes = Recipe.order(id: :desc)
    end
    render json: @recipes, root: API_ROOT
  end
end
