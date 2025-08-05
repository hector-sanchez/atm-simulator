require 'rails_helper'

RSpec.describe Card, type: :model do
  let(:account) { create(:account) }
  let(:card) { create(:card, account: account) }

  describe 'associations' do
    it 'belongs to account' do
      expect(card.account).to eq(account)
    end
  end

  describe 'validations' do
    it 'validates presence of required fields' do
      card = build(:card, card_number: nil, pin: nil, cvc: nil)
      expect(card).not_to be_valid
      expect(card.errors[:card_number]).to include("can't be blank")
    end

    it 'validates card_number format' do
      card = build(:card, card_number: '123')
      expect(card).not_to be_valid
      expect(card.errors[:card_number]).to include('must be exactly 16 digits')
    end

    it 'accepts valid 16-digit card number' do
      card = build(:card, card_number: '4532015112830366')
      expect(card).to be_valid
    end

    it 'validates PIN format' do
      card = build(:card, pin: '12')
      expect(card).not_to be_valid
      expect(card.errors[:pin]).to include('must be exactly 4 digits')

      card = build(:card, pin: 'abcd')
      expect(card).not_to be_valid
      expect(card.errors[:pin]).to include('must be exactly 4 digits')
    end

    it 'validates CVC format' do
      card = build(:card, cvc: '12')
      expect(card).not_to be_valid
      expect(card.errors[:cvc]).to include('must be exactly 3 digits')
    end

    it 'validates card_type inclusion' do
      card = build(:card, card_type: 'invalid')
      expect(card).not_to be_valid
      expect(card.errors[:card_type]).to include('is not included in the list')
    end

    it 'validates status inclusion' do
      card = build(:card, status: 'invalid')
      expect(card).not_to be_valid
      expect(card.errors[:status]).to include('is not included in the list')
    end

    it 'validates expiration_date is in future on create' do
      card = build(:card, expiration_date: 1.day.ago)
      expect(card).not_to be_valid
      expect(card.errors[:expiration_date]).to include('must be in the future')
    end

    it 'validates uniqueness of card_number and card_token' do
      existing_card = create(:card)
      new_card = build(:card, card_number: existing_card.card_number)
      expect(new_card).not_to be_valid
      expect(new_card.errors[:card_number]).to include('has already been taken')
    end
  end

  describe 'callbacks' do
    it 'generates card_token before validation' do
      card = build(:card)
      expect(card.card_token).to be_nil
      card.valid?
      expect(card.card_token).to be_present
      expect(card.card_token.length).to eq(32)
    end

    it 'extracts last_four_digits from card_number' do
      card = create(:card, card_number: '4532015112830366')
      expect(card.last_four_digits).to eq('0366')
    end

    it 'hashes PIN before save' do
      card = create(:card, pin: '1234')
      expect(card.pin_digest).to be_present
      expect(card.pin_digest).not_to eq('1234')
      expect(BCrypt::Password.new(card.pin_digest)).to eq('1234')
    end

    it 'hashes CVC before save' do
      card = create(:card, cvc: '123')
      expect(card.cvc_digest).to be_present
      expect(card.cvc_digest).not_to eq('123')
      expect(BCrypt::Password.new(card.cvc_digest)).to eq('123')
    end
  end

  # describe 'encryption' do
  #   it 'encrypts card_number' do
  #     card = create(:card, card_number: '4532015112830366')
  #
  #     # Check that the raw database value is encrypted
  #     raw_value = Card.connection.select_value(
  #       "SELECT card_number FROM cards WHERE id = #{card.id}"
  #     )
  #     expect(raw_value).not_to eq('4532015112830366')
  #
  #     # But the model can decrypt it
  #     expect(card.card_number).to eq('4532015112830366')
  #   end
  # end

  describe 'scopes' do
    let!(:active_card) { create(:card, :visa, status: 'active') }
    let!(:blocked_card) { create(:card, :mastercard, status: 'blocked') }
    let!(:expired_card) {
      card = build(:card, expiration_date: 1.day.ago, card_number: '6011111111111117')
      card.send(:generate_card_token)
      card.send(:extract_last_four_digits)
      card.send(:hash_pin)
      card.send(:hash_cvc)
      card.save(validate: false)
      card
    }

    it 'active scope returns only active cards' do
      expect(Card.active).to include(active_card, expired_card) # expired_card has status 'active' but is date-expired
      expect(Card.active).not_to include(blocked_card)
    end

    it 'expired scope returns cards past expiration' do
      expect(Card.expired).to include(expired_card)
      expect(Card.expired).not_to include(active_card, blocked_card)
    end

    it 'valid_cards scope returns active and non-expired cards' do
      expect(Card.valid_cards).to include(active_card)
      expect(Card.valid_cards).not_to include(blocked_card, expired_card)
    end
  end

  describe 'instance methods' do
    describe '#active?' do
      it 'returns true for active status' do
        card = create(:card, status: 'active')
        expect(card.active?).to be true
      end

      it 'returns false for non-active status' do
        card = create(:card, status: 'blocked')
        expect(card.active?).to be false
      end
    end

    describe '#expired?' do
      it 'returns true for expired cards' do
        card = build(:card, expiration_date: 1.day.ago)
        card.send(:generate_card_token)
        card.send(:extract_last_four_digits)
        card.send(:hash_pin)
        card.send(:hash_cvc)
        card.save(validate: false) # Skip validation for test setup
        expect(card.expired?).to be true
      end

      it 'returns false for valid cards' do
        card = create(:card, expiration_date: 1.day.from_now)
        expect(card.expired?).to be false
      end
    end

    describe '#valid_for_use?' do
      it 'returns true for active and non-expired cards' do
        card = create(:card, status: 'active', expiration_date: 1.year.from_now)
        expect(card.valid_for_use?).to be true
      end

      it 'returns false for blocked cards' do
        card = create(:card, :blocked)
        expect(card.valid_for_use?).to be false
      end

      it 'returns false for expired cards' do
        card = build(:card, expiration_date: 1.day.ago)
        card.send(:generate_card_token)
        card.send(:extract_last_four_digits)
        card.send(:hash_pin)
        card.send(:hash_cvc)
        card.save(validate: false)
        expect(card.valid_for_use?).to be false
      end
    end

    describe '#formatted_display' do
      it 'shows masked card number' do
        card = create(:card, card_number: '4532015112830366')
        expect(card.formatted_display).to eq('****0366')
      end
    end

    describe '#authenticate_pin' do
      it 'returns true for correct PIN' do
        card = create(:card, pin: '1234')
        expect(card.authenticate_pin('1234')).to be true
      end

      it 'returns false for incorrect PIN' do
        card = create(:card, pin: '1234')
        expect(card.authenticate_pin('9999')).to be false
      end
    end

    describe '#authenticate_cvc' do
      it 'returns true for correct CVC' do
        card = create(:card, cvc: '123')
        expect(card.authenticate_cvc('123')).to be true
      end

      it 'returns false for incorrect CVC' do
        card = create(:card, cvc: '123')
        expect(card.authenticate_cvc('999')).to be false
      end
    end
  end

  describe 'factory traits' do
    it 'creates visa card' do
      card = create(:card, :visa)
      expect(card.card_type).to eq('visa')
      expect(card.card_number).to eq('4532015112830366')
    end

    it 'creates blocked card' do
      card = create(:card, :blocked)
      expect(card.status).to eq('blocked')
    end

    it 'creates expired card' do
      card = build(:card, expiration_date: 1.day.ago)
      card.send(:generate_card_token)
      card.send(:extract_last_four_digits)
      card.send(:hash_pin)
      card.send(:hash_cvc)
      card.save(validate: false)
      expect(card.expired?).to be true
    end

    it 'creates card with custom PIN' do
      card = create(:card, :with_custom_pin, custom_pin: '9876')
      expect(card.authenticate_pin('9876')).to be true
    end
  end
end
