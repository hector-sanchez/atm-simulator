require 'rails_helper'

RSpec.describe CardAuthenticationService do
  let(:account) { create(:account) }
  let!(:card) { create(:card, account: account, card_number: '4532015112830366', pin: '1234') }

  describe '.authenticate' do
    context 'with valid card number and PIN' do
      it 'returns success result with card' do
        result = CardAuthenticationService.authenticate('4532015112830366', '1234')

        expect(result.success?).to be true
        expect(result.card).to eq(card)
        expect(result.error).to be_nil
      end
    end

    context 'with invalid inputs' do
      it 'returns failure for blank card number' do
        result = CardAuthenticationService.authenticate('', '1234')

        expect(result.failure?).to be true
        expect(result.card).to be_nil
        expect(result.error).to eq('Card number is required')
      end

      it 'returns failure for invalid card number format' do
        result = CardAuthenticationService.authenticate('123', '1234')

        expect(result.failure?).to be true
        expect(result.error).to eq('Invalid card number format')
      end

      it 'returns failure for blank PIN' do
        result = CardAuthenticationService.authenticate('4532015112830366', '')

        expect(result.failure?).to be true
        expect(result.error).to eq('PIN is required')
      end

      it 'returns failure for invalid PIN format' do
        result = CardAuthenticationService.authenticate('4532015112830366', '12')

        expect(result.failure?).to be true
        expect(result.error).to eq('Invalid PIN format')
      end

      it 'cleans card number input (removes spaces and dashes)' do
        result = CardAuthenticationService.authenticate('4532-0151-1283-0366', '1234')

        expect(result.success?).to be true
      end
    end

    context 'with non-existent card' do
      it 'returns failure for card not found' do
        result = CardAuthenticationService.authenticate('9999999999999999', '1234')

        expect(result.failure?).to be true
        expect(result.error).to eq('Invalid card number')
      end
    end

    context 'with incorrect PIN' do
      it 'returns failure for wrong PIN' do
        result = CardAuthenticationService.authenticate('4532015112830366', '9999')

        expect(result.failure?).to be true
        expect(result.error).to eq('Invalid PIN')
      end
    end

    context 'with blocked card' do
      let(:blocked_card) { create(:card, :blocked, card_number: '5555555555554444', pin: '1234') }

      it 'returns failure for blocked card' do
        blocked_card # ensure card exists
        result = CardAuthenticationService.authenticate('5555555555554444', '1234')

        expect(result.failure?).to be true
        expect(result.error).to eq('Card is blocked. Please contact your bank.')
      end
    end

    context 'with suspended card' do
      let(:suspended_card) { create(:card, :suspended, card_number: '6011111111111117', pin: '1234') }

      it 'returns failure for suspended card' do
        suspended_card # ensure card exists
        result = CardAuthenticationService.authenticate('6011111111111117', '1234')

        expect(result.failure?).to be true
        expect(result.error).to eq('Card is suspended. Please contact your bank.')
      end
    end

    context 'with expired card' do
      let(:expired_card) { create(:card, :expired, card_number: '4111111111111111', pin: '1234') }

      it 'returns failure for expired card' do
        expired_card # ensure card exists
        result = CardAuthenticationService.authenticate('4111111111111111', '1234')

        expect(result.failure?).to be true
        expect(result.error).to eq('Card has expired')
      end
    end
  end

  describe 'AuthenticationResult' do
    it 'provides convenience methods' do
      success_result = AuthenticationResult.success(card)
      failure_result = AuthenticationResult.failure('Test error')

      expect(success_result.success?).to be true
      expect(success_result.failure?).to be false
      expect(success_result.card).to eq(card)
      expect(success_result.error).to be_nil

      expect(failure_result.success?).to be false
      expect(failure_result.failure?).to be true
      expect(failure_result.card).to be_nil
      expect(failure_result.error).to eq('Test error')
      expect(failure_result.error_message).to eq('Test error')
    end
  end
end
