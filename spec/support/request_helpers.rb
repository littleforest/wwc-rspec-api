module RequestHelpers
  def auth_header(user)
    if user
      { "HTTP_AUTHORIZATION" => "Bearer #{user.auth_token}" }
    end
  end

  def bad_auth_header
    { "HTTP_AUTHORIZATION" => "Bearer badtoken" }
  end

  def json
    JSON.parse(response.body)
  end
end
