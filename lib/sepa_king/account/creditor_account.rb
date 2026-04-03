# frozen_string_literal: true

module SEPA
  class CreditorAccount < Account
    attr_accessor :creditor_identifier

    validates_with CreditorIdentifierValidator, message: 'is invalid'

    def initiating_party_id(builder)
      builder.Id do
        builder.OrgId do
          builder.Othr do
            builder.Id(creditor_identifier)
          end
        end
      end
    end
  end
end
