module WebmockHelpers
  def mailchimp_add_member_success
    stub_request(:post, /api.mailchimp.com/).to_return(status: 200)
  end

  def mailchimp_add_member_failure
    stub_request(:post, /api.mailchimp.com/).to_return(status: 422)
  end

  def more_complicated_example_success(email)
    stub_request(:post, 'https://api.mailchimp.com/3.0/lists/list_id_abcde/members').
      with(
        body: {
          email_address: email,
          status: 'subscribed',
        }
    ).to_return(
      status: 200,
      body: {
        id: 'some_mailchimp_id',
        email_address: email
      }.to_json,
      headers: {},
    )
  end

  def more_complicated_example_failure(email)
    stub_request(:post, 'https://api.mailchimp.com/3.0/lists/list_id_abcde/members').
      with(
        body: {
          email_address: email,
          status: 'subscribed',
        }
    ).to_return(
      status: 422,
      body: {
        type: 'some_mailchimp_error_type',
        detail: 'The user could not be added because the email address is malformed',
      }.to_json,
      headers: {},
    )
  end
end
