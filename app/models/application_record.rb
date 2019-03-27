# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def error_messages
    errors.full_messages.to_sentence
  end
end
