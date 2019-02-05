require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    user = build(:user)
    expect(user.valid?).to be true
  end

  it "saves password" do
    user = create(:user, password: "supersecret", password_confirmation: "supersecret")
    expect(user.authenticate('wrong_password')).to be false
    expect(user.authenticate('supersecret')).to eq user
  end

  it "saves auth_token on create only" do
    user = create(:user)
    expect(user.auth_token).to_not be nil
    token = user.auth_token
    user.update!(email: "new@example.com")
    expect(user.auth_token).to eq token
  end
end
