class API::V1::AddToMailingList
  def initialize(user)
    @user = user
  end

  def call
    # Code that handles adding the user email to a mailing list.  Will likely
    # be calling a third-party API like Mailchimp.
  end
end
