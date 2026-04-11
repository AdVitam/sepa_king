# frozen_string_literal: true

module SEPA
  module TestData
    # Debtor (Schuldner) — CreditTransfer parent account
    DEBTOR_NAME = 'Schuldner GmbH'
    DEBTOR_IBAN = 'DE87200500001234567890'
    DEBTOR_BIC  = 'BANKDEFFXXX'

    # Creditor (Gläubiger) — DirectDebit parent account
    CREDITOR_NAME       = 'Gläubiger GmbH'
    CREDITOR_IDENTIFIER = 'DE98ZZZ09999999999'

    # Credit transfer transaction recipient
    CT_TX_NAME = 'Telekomiker AG'
    CT_TX_IBAN = 'DE37112589611964645802'
    CT_TX_BIC  = 'PBNKDEFF370'

    # Direct debit transaction payer (factory profile)
    DD_TX_NAME = 'Müller & Schmidt oHG'
    DD_TX_IBAN = 'DE68210501700012345678'
    DD_TX_BIC  = 'GENODEF1JEV'

    # Direct debit transaction payer (alternate profile, used in subject blocks)
    DD_TX_ALT_NAME = 'Zahlemann & Söhne GbR'
    DD_TX_ALT_IBAN = 'DE21500500009876543210'
    DD_TX_ALT_BIC  = 'SPUEDE2UXXX'

    # LEI
    LEI      = '529900T8BM49AURSDO55'
    LEI_ALT  = '529900ABCDEFGHIJKL19'
    LEI_ALT2 = 'ABCDEFGHIJKLMNOPQR30'
  end
end

# Default profiles used by factory helpers when a test does not specify one.
DEFAULT_CT_PROFILE = SEPA::Profiles::ISO::SCT_03
DEFAULT_DD_PROFILE = SEPA::Profiles::ISO::SDD_02

# Profile matrices: used by specs to iterate a setup over every ISO variant.
ALL_CT_PROFILES = [
  SEPA::Profiles::ISO::SCT_03,
  SEPA::Profiles::ISO::SCT_09,
  SEPA::Profiles::ISO::SCT_13,
  SEPA::Profiles::ISO::SCT_EPC_002_03,
  SEPA::Profiles::ISO::SCT_EPC_003_03
].freeze

ALL_DD_PROFILES = [
  SEPA::Profiles::ISO::SDD_02,
  SEPA::Profiles::ISO::SDD_08,
  SEPA::Profiles::ISO::SDD_12,
  SEPA::Profiles::ISO::SDD_EPC_002_02,
  SEPA::Profiles::ISO::SDD_EPC_003_02
].freeze

LEI_CT_PROFILES = [SEPA::Profiles::ISO::SCT_09, SEPA::Profiles::ISO::SCT_13].freeze
LEI_DD_PROFILES = [SEPA::Profiles::ISO::SDD_08, SEPA::Profiles::ISO::SDD_12].freeze

def credit_transfer_message(attributes = {})
  SEPA::CreditTransfer.new(profile: DEFAULT_CT_PROFILE,
                           name: SEPA::TestData::DEBTOR_NAME,
                           bic: SEPA::TestData::DEBTOR_BIC,
                           iban: SEPA::TestData::DEBTOR_IBAN, **attributes)
end

def direct_debit_message(attributes = {})
  SEPA::DirectDebit.new(profile: DEFAULT_DD_PROFILE,
                        name: SEPA::TestData::CREDITOR_NAME,
                        bic: SEPA::TestData::DEBTOR_BIC,
                        iban: SEPA::TestData::DEBTOR_IBAN,
                        creditor_identifier: SEPA::TestData::CREDITOR_IDENTIFIER, **attributes)
end

# Convenience helpers for the "build a fresh message with a block setup" pattern,
# used by specs that assert the same transaction setup against multiple profiles.
def build_ct(profile, account_attrs = {}, &setup)
  sct = credit_transfer_message(profile: profile, **account_attrs)
  setup&.call(sct)
  sct
end

def build_dd(profile, account_attrs = {}, &setup)
  sdd = direct_debit_message(profile: profile, **account_attrs)
  setup&.call(sdd)
  sdd
end

def credit_transfer_transaction(attributes = {})
  { name: SEPA::TestData::CT_TX_NAME,
    bic: SEPA::TestData::CT_TX_BIC,
    iban: SEPA::TestData::CT_TX_IBAN,
    amount: 102.50,
    reference: 'XYZ-1234/123',
    remittance_information: 'Rechnung vom 22.08.2013' }.merge(attributes)
end

def direct_debit_transaction(attributes = {})
  { name: SEPA::TestData::DD_TX_NAME,
    bic: SEPA::TestData::DD_TX_BIC,
    iban: SEPA::TestData::DD_TX_IBAN,
    amount: 750.00,
    reference: 'XYZ/2013-08-ABO/6789',
    remittance_information: 'Vielen Dank für Ihren Einkauf!',
    mandate_id: 'K-08-2010-42123',
    mandate_date_of_signature: Date.new(2010, 7, 25),
    requested_date: Date.today + 1 }.merge(attributes)
end

def direct_debit_transaction_alt(attributes = {})
  { name: SEPA::TestData::DD_TX_ALT_NAME,
    bic: SEPA::TestData::DD_TX_ALT_BIC,
    iban: SEPA::TestData::DD_TX_ALT_IBAN,
    amount: 39.99,
    reference: 'XYZ/2013-08-ABO/12345',
    remittance_information: 'Unsere Rechnung vom 10.08.2013',
    mandate_id: 'K-02-2011-12345',
    mandate_date_of_signature: Date.new(2011, 1, 25) }.merge(attributes)
end
