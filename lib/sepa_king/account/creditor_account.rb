# frozen_string_literal: true

module SEPA
  class CreditorAccount < Account
    attr_accessor :creditor_identifier

    validates_with CreditorIdentifierValidator, message: 'is invalid'

    def initiating_party_id(builder)
      build_organisation_id(builder, creditor_identifier)
    end
  end
end
