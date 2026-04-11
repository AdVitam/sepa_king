# frozen_string_literal: true

module SEPA
  CreditTransferGroup = Data.define(
    :requested_date,
    :batch_booking,
    :service_level,
    :category_purpose,
    :instruction_priority,
    :charge_bearer,
    :debtor_agent_instruction
  )

  class CreditTransfer < Message
    FAMILY = :credit_transfer
    XML_MAIN_TAG = :CstmrCdtTrfInitn

    self.account_class = DebtorAccount
    self.transaction_class = CreditTransferTransaction

    private

    def transaction_group(transaction)
      CreditTransferGroup.new(
        requested_date: transaction.requested_date,
        batch_booking: transaction.batch_booking,
        service_level: transaction.service_level,
        category_purpose: transaction.category_purpose,
        instruction_priority: transaction.instruction_priority,
        charge_bearer: transaction.charge_bearer || (transaction.service_level ? 'SLEV' : nil),
        debtor_agent_instruction: transaction.debtor_agent_instruction
      )
    end
  end
end
