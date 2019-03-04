class Recipe < ApplicationRecord
  belongs_to :user

  def self.retrieve_all(user=nil)
  end

  def self.search(q)
  end
end
