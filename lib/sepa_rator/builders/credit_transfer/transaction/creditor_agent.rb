# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        class CreditorAgent < Stage
          def call
            return unless transaction.bic || transaction.agent_lei

            builder.CdtrAgt do
              XmlBuilder.build_agent_bic(
                builder, transaction.bic, profile,
                fallback: false, lei: transaction.agent_lei
              )
            end
          end
        end
      end
    end
  end
end
