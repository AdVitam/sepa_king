# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      module Transaction
        class PaymentId < Stage
          def call
            builder.PmtId do
              builder.InstrId(transaction.instruction) if transaction.instruction && !transaction.instruction.empty?
              builder.EndToEndId(transaction.reference)
              builder.UETR(transaction.uetr) if transaction.uetr && !transaction.uetr.empty?
            end
          end
        end
      end
    end
  end
end
