# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_secure_token :auth_token

  validates :email, presence: true, uniqueness: true

  before_validation :downcase_email

  has_many :recipes

  private

  def downcase_email
    self.email = email.downcase
  end
end
