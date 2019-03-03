# frozen_string_literal: true

class API::V1::ProfileController < API::V1::APIController
  before_action :authenticate

  def show
    render json: current_user, root: API_ROOT
  end

  def update
    if current_user.update(update_params)
      render json: current_user, root: API_ROOT
    else
      render json: { error: current_user.errors.full_messages.to_sentence},
             root: API_ROOT, status: :unprocessable_entity
    end
  end

  private

  def update_params
    params.permit(:email, :username)
  end
end
