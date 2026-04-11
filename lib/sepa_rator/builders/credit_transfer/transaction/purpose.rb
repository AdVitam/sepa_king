# frozen_string_literal: true

module SEPA
  module Builders
    module CreditTransfer
      module Transaction
        class Purpose < Stage
          def call
            XmlBuilder.build_purpose(builder, transaction.purpose_code)
          end
        end
      end
    end
  end
end
