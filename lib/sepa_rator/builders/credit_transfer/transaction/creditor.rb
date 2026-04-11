# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        class Creditor < Stage
          def call
            builder.Cdtr do
              builder.Nm(transaction.name)
              XmlBuilder.build_postal_address(builder, transaction.creditor_address)
              XmlBuilder.build_contact_details(builder, transaction.creditor_contact_details)
            end
          end
        end
      end
    end
  end
end
