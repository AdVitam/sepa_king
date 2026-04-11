# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        class UltimateCreditor < Stage
          def call
            return unless transaction.ultimate_creditor_name

            builder.UltmtCdtr do
              builder.Nm(transaction.ultimate_creditor_name)
            end
          end
        end
      end
    end
  end
end
