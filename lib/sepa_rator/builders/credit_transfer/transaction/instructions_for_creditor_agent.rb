# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        # Unbounded InstrForCdtrAgt blocks. Profile must advertise the
        # :instructions_for_creditor_agent capability (EPC-only schemas
        # don't define this element).
        class InstructionsForCreditorAgent < Stage
          def call
            return unless profile.supports?(:instructions_for_creditor_agent)
            return unless transaction.instructions_for_creditor_agent

            transaction.instructions_for_creditor_agent.each do |instr|
              builder.InstrForCdtrAgt do
                builder.Cd(instr[:code]) if instr[:code]
                builder.InstrInf(instr[:instruction_info]) if instr[:instruction_info]
              end
            end
          end
        end
      end
    end
  end
end
