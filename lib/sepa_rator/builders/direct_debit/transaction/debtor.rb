# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      module Transaction
        class Debtor < Stage
          def call
            builder.Dbtr do
              builder.Nm(transaction.name)
              XmlBuilder.build_postal_address(builder, transaction.debtor_address)
              XmlBuilder.build_contact_details(builder, transaction.debtor_contact_details)
            end
          end
        end
      end
    end
  end
end
