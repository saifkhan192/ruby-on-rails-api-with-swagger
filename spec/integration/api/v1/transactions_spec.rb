# frozen_string_literal: true

# spec/integration/api/v1/transactions_spec.rb

require 'swagger_helper'

RSpec.describe 'api/v1/transactions', type: :request do
  before do
    stub_request(:get, 'https://mock-transactions.free.beeceptor.com/mock_transactions')
      .to_return(
        status: 200,
        body: {
          transactions: [
            {
              transaction_id: '1',
              points: 10,
              expiration_time: '2024-09-10T10:00:00Z'
            },
            {
              transaction_id: '2',
              points: 20,
              expiration_time: '2024-09-05T11:00:00Z'
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
  path '/api/v1/transactions/single' do
    post 'Creates a transaction' do
      tags 'Transactions'
      consumes 'application/json'
      parameter name: :transaction, in: :body, schema: {
        type: :object,
        properties: {
          transaction_id: { type: :string },
          points: { type: :integer },
          user_id: { type: :string }
        },
        required: %w[transaction_id points user_id]
      }

      response '201', 'transaction created' do
        let(:transaction) { { transaction_id: '1', points: 10, user_id: 1 } }
        run_test!
      end

      response '404', 'invalid request' do
        let(:transaction) { { transaction_id: '123', points: nil, user_id: 1 } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:transaction) { { transaction_id: '1', points: 20, user_id: 1 } }
        run_test!
      end
    end
  end

  path '/api/v1/transactions/bulk' do
    post 'Creates multiple transactions' do
      tags 'Transactions'
      consumes 'application/json'
      parameter name: :transactions, in: :body, schema: {
        type: :object,
        properties: {
          transactions: {
            type: :array,
            items: {
              type: :object,
              properties: {
                transaction_id: { type: :string },
                points: { type: :integer },
                user_id: { type: :string }
              },
              required: %w[transaction_id points user_id]
            }
          }
        },
        required: ['transactions']
      }

      response '201', 'transactions created' do
        let(:transactions) { { transactions: [{ transaction_id: '1', points: 10, user_id: 1 }] } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:transactions) { { transactions: [{ transaction_id: '1', points: nil, user_id: 1 }] } }
        run_test!
      end
    end
  end
end
