# frozen_string_literal: true

class API::V1::UserSerializer < ActiveModel::Serializer
  attributes :id,
             :email,
             :username,
             :auth_token
end
