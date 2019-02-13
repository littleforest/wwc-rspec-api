# frozen_string_literal: true

class API::V1::APIController < ApplicationController
  skip_before_action :verify_authenticity_token

  API_ROOT = 'payload'
end
