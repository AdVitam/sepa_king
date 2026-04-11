# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        # Transaction-level InstrForDbtrAgt. Serialized as plain text in older
        # schemas and as a structured {Cd, InstrInf} block in pain.001.001.13.
        class TxnInstructionForDebtorAgent < Stage
          def call
            return unless profile.supports?(:txn_instruction_for_debtor_agent)
            return unless transaction.instruction_for_debtor_agent || transaction.instruction_for_debtor_agent_code

            if profile.features.instr_for_dbtr_agt_format == :structured
              builder.InstrForDbtrAgt do
                builder.Cd(transaction.instruction_for_debtor_agent_code) if transaction.instruction_for_debtor_agent_code
                builder.InstrInf(transaction.instruction_for_debtor_agent) if transaction.instruction_for_debtor_agent
              end
            elsif transaction.instruction_for_debtor_agent
              builder.InstrForDbtrAgt(transaction.instruction_for_debtor_agent)
            end
          end
        end
      end
    end
  end
end
