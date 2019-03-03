class API::V1::RecipeSerializer < ActiveModel::Serializer
  attributes :id,
             :title,
             :description
end
