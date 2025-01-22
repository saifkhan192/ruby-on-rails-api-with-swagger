# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_id, :points, :user_id, presence: true
end
