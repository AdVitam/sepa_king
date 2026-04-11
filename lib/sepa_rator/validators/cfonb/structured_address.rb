# frozen_string_literal: true

module SEPA
  module Validators
    module CFONB
      # CFONB (and the broader EPC 2024+ migration) requires postal addresses
      # to be carried as structured fields (StrtNm, PstCd, TwnNm, …) rather
      # than the legacy `AdrLine` unstructured format. Banks that implement
      # the CFONB guidelines reject files whose addresses are populated only
      # via `address_line1` / `address_line2`.
      #
      # This validator runs during `Message#add_transaction` and raises a
      # `ValidationError` as soon as it sees a transaction-level address
      # that uses AdrLine without any structured field.
      class StructuredAddress
        TRANSACTION_ADDRESS_ACCESSORS = %i[creditor_address debtor_address].freeze

        def self.validate(transaction, profile)
          TRANSACTION_ADDRESS_ACCESSORS.each do |accessor|
            next unless transaction.respond_to?(accessor)

            enforce!(transaction.public_send(accessor), accessor, profile)
          end

          # DD transactions can override the PmtInf creditor — its address
          # is serialised in `PmtInf/Cdtr` and must follow the same rule.
          return unless transaction.respond_to?(:creditor_account) && transaction.creditor_account

          enforce!(transaction.creditor_account.address, 'creditor_account.address', profile)
        end

        def self.enforce!(address, label, profile)
          return if address.nil?
          return if address.structured?

          raise SEPA::ValidationError,
                "[#{profile.id}] #{label} must use structured fields " \
                '(StrtNm, PstCd, TwnNm, …), not AdrLine (CFONB rule)'
        end
      end
    end
  end
end
