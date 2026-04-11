# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      module Transaction
        class DebtorAgent < Stage
          def call
            builder.DbtrAgt do
              XmlBuilder.build_agent_bic(
                builder, transaction.bic, profile,
                lei: transaction.agent_lei
              )
            end
          end
        end
      end
    end
  end
end
