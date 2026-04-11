# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      module Transaction
        class UltimateDebtor < Stage
          def call
            return unless transaction.ultimate_debtor_name

            builder.UltmtDbtr do
              builder.Nm(transaction.ultimate_debtor_name)
            end
          end
        end
      end
    end
  end
end
