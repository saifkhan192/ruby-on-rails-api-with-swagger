# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it 'is valid with valid attributes' do
    transaction = Transaction.new(transaction_id: '123', points: 100, user_id: 'user_1')
    expect(transaction).to be_valid
  end

  it 'is not valid without a transaction_id' do
    transaction = Transaction.new(points: 100, user_id: 'user_1')
    expect(transaction).to_not be_valid
  end

  it 'is not valid without points' do
    transaction = Transaction.new(transaction_id: '123', user_id: 'user_1')
    expect(transaction).to_not be_valid
  end

  it 'is not valid without a user_id' do
    transaction = Transaction.new(transaction_id: '123', points: 100)
    expect(transaction).to_not be_valid
  end
end
