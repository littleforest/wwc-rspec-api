# frozen_string_literal: true

class API::V1::RegistrationsController < API::V1::APIController
  def create
    @user = User.new(user_params)
    if @user.save
      service = API::V1::AddToMailingList.new(@user)
      service.call
      render json: @user, root: API_ROOT
    else
      render json: { error: @user.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end
