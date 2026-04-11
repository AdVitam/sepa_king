# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      module Transaction
        class DebtorAccount < Stage
          def call
            XmlBuilder.build_iban_account(builder, :DbtrAcct, transaction.iban)
          end
        end
      end
    end
  end
end
