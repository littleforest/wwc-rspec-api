class Recipe < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  def self.retrieve_all(user=nil)
    recipes = user ? Recipe.where.not(user: user) : Recipe.all
    recipes.order(id: :desc)
  end

  def self.search(q)
    return Recipe.all if q.blank?
    Recipe.where(title: q)
  end
end
