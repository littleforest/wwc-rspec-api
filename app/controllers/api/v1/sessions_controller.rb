class API::V1::SessionsController < API::V1::APIController
  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      render json: @user, root: API_ROOT
    else
      render json: { error: 'Invalid email or password' },
        status: :unprocessable_entity
    end
  end
end
