# frozen_string_literal: true

module SEPA
  module Profiles
    # Maps `(family, country, version)` triples to the recommended profile.
    # `country: nil` holds the generic EPC fallback used for countries
    # without dedicated profiles.
    module CountryDefaults
      R = ProfileRegistry

      # ── Default fallback (generic SEPA — EPC) ──────────────────────────

      R.set_country_default(family: :credit_transfer, country: nil, version: :latest,
                            profile: EPC::SCT_13)
      R.set_country_default(family: :credit_transfer, country: nil, version: :v13,
                            profile: EPC::SCT_13)
      R.set_country_default(family: :credit_transfer, country: nil, version: :v09,
                            profile: EPC::SCT_09)

      R.set_country_default(family: :direct_debit, country: nil, version: :latest,
                            profile: EPC::SDD_12)
      R.set_country_default(family: :direct_debit, country: nil, version: :v12,
                            profile: EPC::SDD_12)
      R.set_country_default(family: :direct_debit, country: nil, version: :v08,
                            profile: EPC::SDD_08)

      # ── France → CFONB ────────────────────────────────────────────────

      R.set_country_default(family: :credit_transfer, country: :fr, version: :latest,
                            profile: CFONB::SCT_13)
      R.set_country_default(family: :credit_transfer, country: :fr, version: :v13,
                            profile: CFONB::SCT_13)
      R.set_country_default(family: :credit_transfer, country: :fr, version: :v09,
                            profile: CFONB::SCT_09)

      R.set_country_default(family: :direct_debit, country: :fr, version: :latest,
                            profile: CFONB::SDD_12)
      R.set_country_default(family: :direct_debit, country: :fr, version: :v12,
                            profile: CFONB::SDD_12)
      R.set_country_default(family: :direct_debit, country: :fr, version: :v08,
                            profile: CFONB::SDD_08)

      # ── Germany → DK / DFÜ ────────────────────────────────────────────

      R.set_country_default(family: :credit_transfer, country: :de, version: :latest,
                            profile: DK::SCT_13_GBIC5)
      R.set_country_default(family: :credit_transfer, country: :de, version: :v13,
                            profile: DK::SCT_13_GBIC5)
      R.set_country_default(family: :credit_transfer, country: :de, version: :v09,
                            profile: DK::SCT_09_GBIC5)

      R.set_country_default(family: :direct_debit, country: :de, version: :latest,
                            profile: DK::SDD_12_GBIC5)
      R.set_country_default(family: :direct_debit, country: :de, version: :v12,
                            profile: DK::SDD_12_GBIC5)
      R.set_country_default(family: :direct_debit, country: :de, version: :v08,
                            profile: DK::SDD_08_GBIC5)
    end
  end
end
