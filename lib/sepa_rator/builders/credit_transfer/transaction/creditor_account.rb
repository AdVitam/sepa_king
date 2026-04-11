# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        class CreditorAccount < Stage
          def call
            XmlBuilder.build_iban_account(builder, :CdtrAcct, transaction.iban)
          end
        end
      end
    end
  end
end
