class Recipe < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  def self.retrieve_all(user=nil)
  end
end
