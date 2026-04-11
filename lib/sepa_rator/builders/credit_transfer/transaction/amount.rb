# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        class Amount < Stage
          def call
            builder.Amt do
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
end
