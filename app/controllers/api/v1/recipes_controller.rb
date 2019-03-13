# frozen_string_literal: true

class API::V1::RecipesController < API::V1::APIController
  before_action :authenticate_token

  def community
    if params[:q].present?
      @recipes = Recipe.retrieve_all(current_user).where(title: params[:q])
    else
      @recipes = Recipe.retrieve_all(current_user)
    end
    render json: @recipes, root: API_ROOT
  end
end
