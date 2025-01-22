# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :transaction_id
      t.integer :points
      t.string :user_id

      t.timestamps
    end
  end
end
