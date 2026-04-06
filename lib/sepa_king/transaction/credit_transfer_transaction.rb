# frozen_string_literal: true

module SEPA
  class CreditTransferTransaction < Transaction
    attr_accessor :service_level,
                  :category_purpose,
                  :charge_bearer

    CHARGE_BEARERS = %w[DEBT CRED SHAR SLEV].freeze
    EPC_ONLY_SCHEMAS = %w[pain.001.002.03 pain.001.003.03].freeze

    validates_inclusion_of :service_level, in: %w[SEPA URGP], allow_nil: true
    validates_length_of :category_purpose, within: 1..4, allow_nil: true
    validates_inclusion_of :charge_bearer, in: CHARGE_BEARERS, allow_nil: true

    validate { |t| t.validate_requested_date_after(Date.today) }

    def initialize(attributes = {})
      super
      self.service_level ||= 'SEPA' if currency == 'EUR'
    end

    UETR_SCHEMAS = %w[pain.001.001.09 pain.001.001.13].freeze

    # Fields (uetr, bic) are already validated as nil-or-non-empty
    # at add_transaction time, so a nil check is sufficient here.
    def schema_compatible?(schema_name)
      return false if uetr && !UETR_SCHEMAS.include?(schema_name)
      return false if charge_bearer && charge_bearer != 'SLEV' && EPC_ONLY_SCHEMAS.include?(schema_name)

      case schema_name
      when PAIN_001_001_03, PAIN_001_001_09, PAIN_001_001_13
        !self.service_level || (self.service_level == 'SEPA' && currency == 'EUR')
      when PAIN_001_002_03
        bic && !bic.empty? && self.service_level == 'SEPA' && currency == 'EUR'
      when PAIN_001_003_03
        currency == 'EUR'
      when PAIN_001_001_03_CH_02
        currency == 'CHF'
      end
    end
  end
end
