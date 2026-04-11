# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        # MndtRltdInf — CreditTransferMandateData1 (pain.001.001.13 only).
        # No-op for profiles that don't advertise the :mandate_related_info capability.
        class CreditTransferMandate < Stage
          def call
            return unless profile.supports?(:mandate_related_info)
            return unless transaction.credit_transfer_mandate?

            builder.MndtRltdInf do
              builder.MndtId(transaction.credit_transfer_mandate_id) if transaction.credit_transfer_mandate_id
              builder.DtOfSgntr(transaction.credit_transfer_mandate_date_of_signature.iso8601) if transaction.credit_transfer_mandate_date_of_signature
              builder.Frqcy { builder.Tp(transaction.credit_transfer_mandate_frequency) } if transaction.credit_transfer_mandate_frequency
            end
          end
        end
      end
    end
  end
end
