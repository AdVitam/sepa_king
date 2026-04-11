# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      module Transaction
        class Amount < Stage
          def call
            builder.InstdAmt(
              XmlBuilder.format_amount(transaction.amount),
              Ccy: transaction.currency
            )
          end
        end
      end
    end
  end
end
