class Recipe < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  def self.retrieve_all(user=nil)
    recipes = user ? Recipe.where.not(user: user) : Recipe.all
    recipes.order(id: :desc)
  end
end
