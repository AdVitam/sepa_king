# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      class PaymentInformation < Stage
        def call
          message.grouped_transactions.each do |group, transactions|
            builder.PmtInf do
              emit_header(group, transactions)
              emit_payment_type_information(group)
              emit_creditor_info(group)
              emit_creditor_scheme_identification(group)
              transactions.each { |transaction| emit_transaction(transaction, group) }
            end
          end
        end

        private

        def emit_header(group, transactions)
          builder.PmtInfId(message.payment_information_identification(group))
          builder.PmtMtd('DD')
          builder.BtchBookg(group.batch_booking)
          builder.NbOfTxs(transactions.length)
          builder.CtrlSum(XmlBuilder.format_amount(message.amount_total(transactions)))
        end

        def emit_payment_type_information(group)
          builder.PmtTpInf do
            builder.InstrPrty(group.instruction_priority) if group.instruction_priority
            builder.SvcLvl { builder.Cd('SEPA') }
            builder.LclInstrm { builder.Cd(group.local_instrument) }
            builder.SeqTp(group.sequence_type)
          end
        end

        def emit_creditor_info(group)
          builder.ReqdColltnDt(group.requested_date.iso8601)
          builder.Cdtr do
            builder.Nm(group.account.name)
            XmlBuilder.build_postal_address(builder, group.account.address)
            XmlBuilder.build_contact_details(builder, group.account.contact_details)
          end
          XmlBuilder.build_iban_account(builder, :CdtrAcct, group.account.iban)
          builder.CdtrAgt do
            XmlBuilder.build_agent_bic(builder, group.account.bic, profile, lei: group.account.agent_lei)
          end
          builder.ChrgBr(group.charge_bearer)
        end

        def emit_creditor_scheme_identification(group)
          builder.CdtrSchmeId do
            builder.Id do
              builder.PrvtId do
                builder.Othr do
                  builder.Id(group.account.creditor_identifier)
                  builder.SchmeNm { builder.Prtry('SEPA') }
                end
              end
            end
          end
        end

        def emit_transaction(transaction, group)
          txn_context = Context.new(
            message: message,
            profile: profile,
            builder: builder,
            transaction: transaction,
            group: group
          )
          builder.DrctDbtTxInf do
            profile.transaction_stages.each { |stage| stage.call(txn_context) }
          end
        end
      end
    end
  end
end
