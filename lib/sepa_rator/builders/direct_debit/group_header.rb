# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      class GroupHeader < Stage
        def call
          builder.GrpHdr do
            builder.MsgId(message.message_identification)
            builder.CreDtTm(message.creation_date_time)
            builder.NbOfTxs(message.transactions.length)
            builder.CtrlSum(XmlBuilder.format_amount(message.amount_total))
            builder.InitgPty do
              builder.Nm(message.account.name)
              message.account.initiating_party_id(builder, profile)
              XmlBuilder.build_contact_details(builder, message.account.contact_details)
            end
          end
        end
      end
    end
  end
end
