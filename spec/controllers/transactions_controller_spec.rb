require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe "POST #create" do
    let(:customer) { create(:customer) }
    let(:account) { create(:account, customer: customer, balance: 500.00) }
    let(:card) { create(:card, account: account) }
    let(:atm_machine) { create(:atm_machine) }

    before do
      session[:card_id] = card.id
      session[:atm_machine_id] = atm_machine.id
    end

    context "with valid debit transaction" do
      let(:transaction_params) do
        {
          transaction: {
            amount: "100.00",
            transaction_type: "debit"
          }
        }
      end

      it "creates a debit transaction successfully" do
        expect {
          post :create, params: transaction_params, xhr: true, format: :json
        }.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_truthy

        transaction = Transaction.last
        expect(transaction.amount).to eq(100.00)
        expect(transaction.transaction_type).to eq('debit')
        expect(transaction.card).to eq(card)
      end

      it "updates account balance correctly for debit" do
        post :create, params: transaction_params, xhr: true, format: :json

        account.reload
        expect(account.balance).to eq(400.00)
      end
    end

    context "with valid credit transaction" do
      let(:transaction_params) do
        {
          transaction: {
            amount: "50.00",
            transaction_type: "credit"
          }
        }
      end

      it "creates a credit transaction successfully" do
        expect {
          post :create, params: transaction_params, xhr: true, format: :json
        }.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_truthy

        transaction = Transaction.last
        expect(transaction.amount).to eq(50.00)
        expect(transaction.transaction_type).to eq('credit')
        expect(transaction.card).to eq(card)
      end

      it "updates account balance correctly for credit" do
        post :create, params: transaction_params, xhr: true, format: :json

        account.reload
        expect(account.balance).to eq(550.00)
      end
    end

    context "with insufficient funds" do
      let(:transaction_params) do
        {
          transaction: {
            amount: "600.00",
            transaction_type: "debit"
          }
        }
      end

      it "returns error for insufficient funds" do
        post :create, params: transaction_params, xhr: true, format: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['error']).to include('Insufficient funds')

        # Account balance should remain unchanged
        account.reload
        expect(account.balance).to eq(500.00)
      end
    end

    context "without authentication" do
      before do
        session[:card_id] = nil
      end

      let(:transaction_params) do
        {
          transaction: {
            amount: "100.00",
            transaction_type: "debit"
          }
        }
      end

      it "redirects to login" do
        post :create, params: transaction_params, xhr: true, format: :json
        expect(response).to redirect_to(login_path)
      end
    end
  end
end
