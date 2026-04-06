# frozen_string_literal: true

module SEPA
  class Account
    include ActiveModel::Validations
    include AttributeInitializer
    extend Converter

    attr_accessor :name, :iban, :bic, :address

    convert :name, to: :text

    validates_length_of :name, within: 1..70
    validates_with BICValidator, IBANValidator, message: 'is invalid'

    validate do |record|
      next unless record.address

      unless record.address.valid?
        record.address.errors.each do |error|
          record.errors.add(:address, error.full_message)
        end
      end
    end

    def initiating_party_id(builder); end
  end
end
