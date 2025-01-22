# frozen_string_literal: true

require 'net/http'
require 'json'

module Api
  module V1
    class TransactionsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :validate_single_transaction, only: [:single]
      before_action :validate_bulk_transaction, only: [:bulk]

      def single
        transaction = Transaction.new(transaction_params)

        if transaction.save
          render json: { status: 'success', transaction_id: transaction.transaction_id }, status: :created
        else
          render json: { status: 'error', errors: transaction.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      def bulk
        transactions = Transaction.create(bulk_transaction_params[:transactions])
        if transactions.all?(&:persisted?)
          render json: { status: 'success', processed_count: transactions.size }, status: :created
        else
          render json: { status: 'error', errors: transactions.map(&:errors).map(&:full_messages) },
                 status: :unprocessable_entity
        end
      end

      private

      def validate_single_transaction
        # Fetch transactions from the external API
        transactions_data = fetch_transactions_from_vendor
        # Find the transaction in the external data
        result = render_message_for_transaction(transactions_data, params[:transaction_id], params[:points])
        render json: { status: 'error', error: result[:error_message] }, status: result[:status] unless result[:valid]
      end

      def validate_bulk_transaction
        # Fetch transactions from the external API
        transactions_data = fetch_transactions_from_vendor
        # Find the transaction in the external data
        transactions = bulk_transaction_params[:transactions]
        result = {}
        if transactions.any? do |transaction|
          result = render_message_for_transaction(transactions_data, transaction[:transaction_id], transaction[:points])
          true unless result[:valid]
        end
          render json: { status: 'error', error: result[:error_message] }, status: result[:status]
        end
      end

      def render_message_for_transaction(transaction_data, transaction_id, points)
        transaction = transaction_data.find { |t| t['transaction_id'] == transaction_id }
        if transaction.nil?
          { valid: false, error_message: "Transaction #{transaction_id} not found.", status: :not_found }
        elsif transaction['points'] != points
          { valid: false, error_message: "Transaction points of #{transaction_id} is inconsistent.", status: :unprocessable_entity }
        elsif !valid_expiration?(transaction['expiration_time'])
          { valid: false, error_message: "Transaction #{transaction_id} has expired.", status: :unprocessable_entity }
        else
          { valid: true }
        end
      end

      def fetch_transactions_from_vendor
        uri = URI('https://mock-transactions.free.beeceptor.com/mock_transactions')
        response = Net::HTTP.get(uri)
        data = JSON.parse(response)
        data['transactions']
      rescue StandardError => e
        # Handle any errors that occur during the HTTP request or JSON parsing
        Rails.logger.error("Error fetching transactions: #{e.message}")
        []
      end

      def valid_expiration?(expiration_time)
        Time.parse(expiration_time) > Time.current
      end

      def transaction_params
        params.require(:transaction).permit(:transaction_id, :points, :user_id)
      end

      def bulk_transaction_params
        params.permit(transactions: %i[transaction_id points user_id])
      end
    end
  end
end
