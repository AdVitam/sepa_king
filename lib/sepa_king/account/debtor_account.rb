# frozen_string_literal: true

module SEPA
  class DebtorAccount < Account
    attr_accessor :initiating_party_identifier

    convert :initiating_party_identifier, to: :text
    validates_length_of :initiating_party_identifier, within: 1..35, allow_nil: true

    def initiating_party_id(builder)
      return unless initiating_party_identifier

      build_organisation_id(builder, initiating_party_identifier)
    end
  end
end
