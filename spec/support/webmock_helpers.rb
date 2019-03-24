module WebmockHelpers
  def mailchimp_add_member_success
    stub_request(:post, /api.mailchimp.com/).to_return(status: 200)
  end

  def mailchimp_add_member_failure
    stub_request(:post, /api.mailchimp.com/).to_return(status: 422)
  end
end
