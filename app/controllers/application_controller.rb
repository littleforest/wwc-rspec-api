# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def authenticate
    authenticate_token || render_unauthorized
  end

  def optionally_authenticate
    authenticate_token
  end

  def current_user
    @user
  end

  private

  def authenticate_token
    authenticate_with_http_token do |token, options|
      @user = User.find_by(auth_token: token)
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render json: { error: 'Unauthorized token' }, status: :unauthorized
  end
end
