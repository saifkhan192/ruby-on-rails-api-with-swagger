# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :controller do
  before do
    # Set the environment variable
    ENV['TRANSACTION_API_URL'] = 'https://mock-transactions.free.beeceptor.com/mock_transactions'
  end

  let(:mocked_transactions) do
    {
      'transactions' => [
        {
          'transaction_id' => '1',
          'points' => '10',
          'expiration_time' => '2024-09-10T10:00:00Z'
        },
        {
          'transaction_id' => '2',
          'points' => '20',
          'expiration_time' => '2024-09-05T11:00:00Z'
        }
        # Add more mocked transactions if needed
      ]
    }
  end

  before do
    # Stub the external API request
    stub_request(:get, ENV['TRANSACTION_API_URL'])
      .to_return(
        status: 200,
        body: mocked_transactions.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'POST #single' do
    let(:valid_params) do
      {
        transaction_id: '1',
        points: 10,
        user_id: '1'
      }
    end

    context 'when the transaction is valid' do
      it 'creates a new transaction and returns success' do
        expect do
          post :single, params: valid_params
          # end.to change(Transaction, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(response.body).to include('success')
          expect(response.body).to include('transaction_id')
        end
      end
    end

    context 'when the transaction does not exist' do
      before do
        stub_request(:get, ENV['TRANSACTION_API_URL'])
          .to_return(
            status: 200,
            body: { 'transactions': [] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns an error' do
        post :single, params: valid_params

        expect(response).to have_http_status(:not_found)
        expect(response.body).to include('Transaction 1 not found.')
      end
    end

    context 'when the transaction points is inconsistent' do
      let(:inconsistent_params) do
        {
          transaction_id: '1',
          points: 999, # Incorrect points
          user_id: '1'
        }
      end

      it 'returns an error' do
        post :single, params: inconsistent_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Transaction points of 1 is inconsistent.')
      end
    end
    context 'when the transaction has expired' do
      let(:expired_transaction) do
        {
          'transactions' => [
            {
              'transaction_id' => '6',
              'points' => '21',
              'expiration_time' => '2024-08-30T12:00:00Z' # Expired date
            }
          ]
        }
      end

      before do
        stub_request(:get, ENV['TRANSACTION_API_URL'])
          .to_return(
            status: 200,
            body: expired_transaction.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      let(:expired_params) do
        {
          transaction_id: '6',
          points: '21',
          user_id: '1'
        }
      end

      it 'returns an error' do
        post :single, params: expired_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Transaction 6 has expired.')
      end
    end
  end

  describe 'POST #bulk' do
    let(:valid_params) do
      {
        "transactions": [
          {
            "transaction_id": '1',
            "points": '10',
            "user_id": '1'
          },
          {
            "transaction_id": '2',
            "points": '20',
            "user_id": '1'
          }
        ]
      }
    end
    context 'with valid attributes' do
      it 'creates multiple transactions' do
        post :bulk, params: valid_params
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['status']).to eq('success')
        expect(JSON.parse(response.body)['processed_count']).to eq(2)
      end
    end

    context 'with invalid attributes' do
      it 'returns an error' do
        transactions_params = {
          transactions: [
            { points: '100', user_id: 'user_1' },
            { transaction_id: '124', points: '200' }
          ]
        }
        post :bulk, params: transactions_params
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['status']).to eq('error').or eq(:not_found)
      end
    end
  end
end
