# frozen_string_literal: true

module SEPA
  DirectDebitGroup = Data.define(
    :requested_date,
    :local_instrument,
    :sequence_type,
    :batch_booking,
    :account,
    :instruction_priority,
    :charge_bearer
  )

  class DirectDebit < Message
    FAMILY = :direct_debit
    XML_MAIN_TAG = :CstmrDrctDbtInitn

    self.account_class = CreditorAccount
    self.transaction_class = DirectDebitTransaction

    validate do |record|
      errors.add(:base, 'CORE, COR1 AND B2B must not be mixed in one message!') if record.transactions.map(&:local_instrument).uniq.size > 1
    end

    private

    def transaction_group(transaction)
      DirectDebitGroup.new(
        requested_date: transaction.requested_date,
        local_instrument: transaction.local_instrument,
        sequence_type: transaction.sequence_type,
        batch_booking: transaction.batch_booking,
        account: transaction.creditor_account || account,
        instruction_priority: transaction.instruction_priority,
        charge_bearer: transaction.charge_bearer || 'SLEV'
      )
    end
  end
end
