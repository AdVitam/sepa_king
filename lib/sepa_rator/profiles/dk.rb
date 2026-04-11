# frozen_string_literal: true

module SEPA
  module Profiles
    # Deutsche Kreditwirtschaft (DK) / DFÜ-Abkommen profiles for EBICS.
    #
    # DK publishes its own XSDs (`pain.001.001.09_AXZ_GBIC5.xsd`,
    # `pain.008.001.08_AXZ_GBIC5.xsd`) that tighten the ISO baseline with
    # a minimum transaction amount of 0.01 and structured postal addresses.
    # The XSDs are not vendored here (licensing) — see
    # `lib/schema/dk/README.md` for wiring instructions.
    module DK
      VALIDATORS = [Validators::DK::MinAmount].freeze

      FEATURES = {
        min_amount: BigDecimal('0.01'),
        requires_structured_address: true
      }.freeze

      # ─── SEPA Credit Transfer ────────────────────────────────────────────

      SCT_09_GBIC5 = ProfileRegistry.register(
        EPC::SCT_09.with(id: 'dk.sct.09.gbic5', features: FEATURES, validators: VALIDATORS)
      )

      SCT_13_GBIC5 = ProfileRegistry.register(
        EPC::SCT_13.with(id: 'dk.sct.13.gbic5', features: FEATURES, validators: VALIDATORS)
      )

      # ─── SEPA Direct Debit ───────────────────────────────────────────────

      SDD_08_GBIC5 = ProfileRegistry.register(
        EPC::SDD_08.with(id: 'dk.sdd.08.gbic5', features: FEATURES, validators: VALIDATORS)
      )

      SDD_12_GBIC5 = ProfileRegistry.register(
        EPC::SDD_12.with(id: 'dk.sdd.12.gbic5', features: FEATURES, validators: VALIDATORS)
      )
    end
  end
end
