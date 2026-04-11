# frozen_string_literal: true

module SEPA
  module Builders
    module DirectDebit
      module Transaction
        class RemittanceInformation < Stage
          def call
            XmlBuilder.build_remittance_information(builder, transaction)
          end
        end
      end
    end
  end
end
