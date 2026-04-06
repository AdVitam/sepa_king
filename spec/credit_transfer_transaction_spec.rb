# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SEPA::CreditTransferTransaction do
  describe :initialize do
    it 'initializes a valid transaction' do
      expect(
        SEPA::CreditTransferTransaction.new(name: 'Telekomiker AG',
                                            iban: 'DE37112589611964645802',
                                            bic: 'PBNKDEFF370',
                                            amount: 102.50,
                                            reference: 'XYZ-1234/123',
                                            remittance_information: 'Rechnung 123 vom 22.08.2013')
      ).to be_valid
    end
  end

  describe :schema_compatible? do
    context 'for pain.001.003.03' do
      it 'succeeds' do
        expect(SEPA::CreditTransferTransaction.new({})).to be_schema_compatible('pain.001.003.03')
      end

      it 'fails for invalid attributes' do
        expect(SEPA::CreditTransferTransaction.new(currency: 'CHF')).not_to be_schema_compatible('pain.001.003.03')
      end
    end

    context 'pain.001.002.03' do
      it 'succeeds for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', service_level: 'SEPA')).to be_schema_compatible('pain.001.002.03')
      end

      it 'fails for invalid attributes' do
        expect(SEPA::CreditTransferTransaction.new(bic: nil)).not_to be_schema_compatible('pain.001.002.03')
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', service_level: 'URGP')).not_to be_schema_compatible('pain.001.002.03')
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', currency: 'CHF')).not_to be_schema_compatible('pain.001.002.03')
      end
    end

    context 'for pain.001.001.03' do
      it 'succeeds for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', currency: 'CHF')).to be_schema_compatible('pain.001.001.03')
        expect(SEPA::CreditTransferTransaction.new(bic: nil)).to be_schema_compatible('pain.001.003.03')
      end
    end

    context 'for pain.001.001.03.ch.02' do
      it 'succeeds for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', currency: 'CHF')).to be_schema_compatible('pain.001.001.03.ch.02')
      end
    end

    context 'for pain.001.001.09' do
      it 'succeeds for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX')).to be_schema_compatible('pain.001.001.09')
        expect(SEPA::CreditTransferTransaction.new(bic: nil)).to be_schema_compatible('pain.001.001.09')
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', currency: 'CHF')).to be_schema_compatible('pain.001.001.09')
      end

      it 'accepts UETR' do
        expect(SEPA::CreditTransferTransaction.new(uetr: '550e8400-e29b-41d4-a716-446655440000'))
          .to be_schema_compatible('pain.001.001.09')
      end
    end

    context 'for pain.001.001.13' do
      it 'succeeds for valid attributes' do
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX')).to be_schema_compatible('pain.001.001.13')
        expect(SEPA::CreditTransferTransaction.new(bic: nil)).to be_schema_compatible('pain.001.001.13')
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', currency: 'CHF')).to be_schema_compatible('pain.001.001.13')
      end

      it 'accepts UETR' do
        expect(SEPA::CreditTransferTransaction.new(uetr: '550e8400-e29b-41d4-a716-446655440000'))
          .to be_schema_compatible('pain.001.001.13')
      end
    end

    context 'UETR schema compatibility' do
      it 'rejects UETR for pain.001.001.03' do
        expect(SEPA::CreditTransferTransaction.new(uetr: '550e8400-e29b-41d4-a716-446655440000'))
          .not_to be_schema_compatible('pain.001.001.03')
      end

      it 'rejects UETR for pain.001.002.03' do
        expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', service_level: 'SEPA', uetr: '550e8400-e29b-41d4-a716-446655440000'))
          .not_to be_schema_compatible('pain.001.002.03')
      end
    end
  end

  context 'Requested date' do
    around { |example| travel_to(Time.new(2025, 6, 15, 12, 0, 0)) { example.run } }

    it 'allows valid value' do
      expect(SEPA::CreditTransferTransaction).to accept(nil, Date.new(1999, 1, 1), Date.today, Date.today.next, Date.today + 2, for: :requested_date)
    end

    it 'does not allow invalid value' do
      expect(SEPA::CreditTransferTransaction).not_to accept(Date.new(1995, 12, 21), Date.today - 1, for: :requested_date)
    end
  end

  context 'Instruction Priority' do
    it 'allows valid value' do
      expect(SEPA::CreditTransferTransaction).to accept(nil, 'HIGH', 'NORM', for: :instruction_priority)
    end

    it 'does not allow invalid value' do
      expect(SEPA::CreditTransferTransaction).not_to accept('', 'LOW', 'high', for: :instruction_priority)
    end
  end

  context 'Charge Bearer' do
    it 'allows valid value' do
      expect(SEPA::CreditTransferTransaction).to accept(nil, 'DEBT', 'CRED', 'SHAR', 'SLEV', for: :charge_bearer)
    end

    it 'does not allow invalid value' do
      expect(SEPA::CreditTransferTransaction).not_to accept('', 'INVALID', 'slev', for: :charge_bearer)
    end
  end

  context 'Charge Bearer schema compatibility' do
    it 'rejects non-SLEV for pain.001.002.03' do
      expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', service_level: 'SEPA', charge_bearer: 'SHAR'))
        .not_to be_schema_compatible('pain.001.002.03')
    end

    it 'rejects non-SLEV for pain.001.003.03' do
      expect(SEPA::CreditTransferTransaction.new(charge_bearer: 'DEBT'))
        .not_to be_schema_compatible('pain.001.003.03')
    end

    it 'accepts SLEV for pain.001.002.03' do
      expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', service_level: 'SEPA', charge_bearer: 'SLEV'))
        .to be_schema_compatible('pain.001.002.03')
    end

    it 'accepts any for pain.001.001.03' do
      expect(SEPA::CreditTransferTransaction.new(charge_bearer: 'SHAR'))
        .to be_schema_compatible('pain.001.001.03')
    end

    it 'accepts any for pain.001.001.09' do
      expect(SEPA::CreditTransferTransaction.new(charge_bearer: 'DEBT'))
        .to be_schema_compatible('pain.001.001.09')
    end

    it 'accepts nil for EPC schemas' do
      expect(SEPA::CreditTransferTransaction.new(bic: 'SPUEDE2UXXX', service_level: 'SEPA', charge_bearer: nil))
        .to be_schema_compatible('pain.001.002.03')
    end
  end

  context 'Category Purpose' do
    it 'allows valid value' do
      expect(SEPA::CreditTransferTransaction).to accept(nil, 'SALA', 'INST', 'X' * 4, for: :category_purpose)
    end

    it 'does not allow invalid value' do
      expect(SEPA::CreditTransferTransaction).not_to accept('', 'X' * 5, for: :category_purpose)
    end
  end
end
