class API::V1::AddToMailingList
  def initialize(user)
    @user = user
  end

  def call
    resp = HTTP
             .basic_auth(user: 'anystring', pass: 'my_mailchimp_api_token')
             .post(
               'https://api.mailchimp.com/3.0/lists/list_id_abcde/members',
               json: {
                 email_address: @user.email,
                 status: 'subscribed',
               }
             )

    body = resp.parse(:json)

    if resp.code == 200
      @user.update(username: body["id"])
      return true
    else
      return false
    end
  end
end
