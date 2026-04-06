# SEPA King — Full Documentation

## Table of Contents

- [Credit Transfer (pain.001)](#credit-transfer-pain001)
- [Direct Debit (pain.008)](#direct-debit-pain008)
- [Addresses](#addresses)
- [Charge Bearer](#charge-bearer)
- [Mandate Amendments](#mandate-amendments)
- [Validators](#validators)
- [Supported Schemas](#supported-schemas)

---

## Credit Transfer (pain.001)

### Account (debtor)

```ruby
sct = SEPA::CreditTransfer.new(
  name: 'Debtor Inc.',             # Required, max 70 chars
  iban: 'DE87200500001234567890',  # Required
  bic:  'BANKDEFFXXX',            # Optional, 8 or 11 chars

  # Optional: postal address of the debtor at PmtInf level
  # Recommended for cross-border payments
  address: SEPA::Address.new(
    country_code: 'DE',
    post_code:    '10115',
    town_name:    'Berlin',
    street_name:  'Hauptstrasse',
    building_number: '42'
  )
)
```

### Transaction (credit)

```ruby
sct.add_transaction(
  # Required
  name:   'Creditor AG',            # max 70 chars
  iban:   'DE37112589611964645802',
  amount: 102.50,                    # positive, max 999_999_999.99

  # Optional
  bic:                    'PBNKDEFF370',       # 8 or 11 chars
  currency:               'EUR',               # ISO 4217, default: EUR
  instruction:            '12345',             # max 35 chars, not sent to creditor
  reference:              'XYZ-1234/123',      # max 35 chars (End-To-End ID)
  remittance_information: 'Invoice 123',       # max 140 chars
  requested_date:         Date.new(2024, 9, 5),
  batch_booking:          true,
  service_level:          'SEPA',              # 'SEPA' or 'URGP' (default: 'SEPA' for EUR)
  category_purpose:       'SALA',              # max 4 chars (e.g., SALA, INST)
  charge_bearer:          'SLEV',              # see Charge Bearer section
  instruction_priority:   'HIGH',              # 'HIGH' or 'NORM'

  # Optional: postal address of the creditor (required for cross-border)
  creditor_address: SEPA::CreditorAddress.new(
    country_code: 'CH',
    address_line1: 'Musterstrasse 123a',
    address_line2: '1234 Musterstadt'
  )
)
```

### Generate XML

```ruby
xml = sct.to_xml                               # pain.001.001.03 (default)
xml = sct.to_xml('pain.001.001.09')            # newer
xml = sct.to_xml('pain.001.001.13')            # latest
xml = sct.to_xml('pain.001.002.03')            # EPC (SEPA-only)
xml = sct.to_xml('pain.001.003.03')            # German DK
xml = sct.to_xml('pain.001.001.03.ch.02')      # Swiss SIX (CHF)
```

---

## Direct Debit (pain.008)

### Account (creditor)

```ruby
sdd = SEPA::DirectDebit.new(
  name:                'Creditor Inc.',          # Required, max 70 chars
  iban:                'DE87200500001234567890',  # Required
  bic:                 'BANKDEFFXXX',            # Optional
  creditor_identifier: 'DE98ZZZ09999999999',     # Required

  # Optional: postal address (recommended for cross-border)
  address: SEPA::Address.new(
    country_code: 'DE',
    town_name:    'Berlin',
    post_code:    '10115'
  )
)
```

### Transaction (debit)

```ruby
sdd.add_transaction(
  # Required
  name:                      'Debtor Corp.',
  iban:                      'DE21500500009876543210',
  amount:                    39.99,
  mandate_id:                'K-02-2011-12345',       # max 35 chars
  mandate_date_of_signature: Date.new(2011, 1, 25),

  # Optional
  bic:                    'SPUEDE2UXXX',
  currency:               'EUR',
  instruction:            '12345',
  reference:              'XYZ/2013-08-ABO/6789',
  remittance_information: 'Thank you!',
  requested_date:         Date.new(2024, 9, 5),
  batch_booking:          true,
  instruction_priority:   'HIGH',
  charge_bearer:          'SLEV',              # see Charge Bearer section

  # Local instrument: 'CORE' (default), 'B2B', or 'COR1' (deprecated)
  local_instrument: 'CORE',

  # Sequence type: 'OOFF' (default), 'FRST', 'RCUR', 'FNAL', 'RPRE' (.08/.12 only)
  sequence_type: 'OOFF',

  # Optional: use a different creditor account for this transaction
  creditor_account: SEPA::CreditorAccount.new(
    name: 'Other Creditor',
    bic: 'RABONL2U',
    iban: 'NL08RABO0135742099',
    creditor_identifier: 'NL53ZZZ091734220000'
  ),

  # Optional: postal address of the debtor (required for cross-border)
  debtor_address: SEPA::DebtorAddress.new(
    country_code: 'CH',
    street_name:  'Musterstrasse',
    building_number: '123a',
    post_code:    '1234',
    town_name:    'Musterstadt'
  ),

  # Optional: mandate amendment fields (see Mandate Amendments section)
  original_mandate_id: 'OLD-MANDATE-123',
  original_debtor_account: 'NL08RABO0135742099',
  same_mandate_new_debtor_agent: false,
  original_creditor_account: nil
)
```

### Generate XML

```ruby
xml = sdd.to_xml                               # pain.008.001.02 (default)
xml = sdd.to_xml('pain.008.001.08')            # newer
xml = sdd.to_xml('pain.008.001.12')            # latest
xml = sdd.to_xml('pain.008.002.02')            # EPC (SEPA-only)
xml = sdd.to_xml('pain.008.003.02')            # German DK
```

---

## Addresses

Addresses can be set at two levels:

1. **Account level** (`address:` on `CreditTransfer.new` or `DirectDebit.new`) — appears in `Dbtr/PstlAdr` or `Cdtr/PstlAdr` at the PmtInf level.
2. **Transaction level** (`creditor_address:` or `debtor_address:`) — appears per transaction.

### Address fields

Use `SEPA::Address.new(...)` (or `SEPA::DebtorAddress` / `SEPA::CreditorAddress`):

| Field | Max length | Schema support |
|-------|-----------|----------------|
| `country_code` | 2 (ISO 3166) | All schemas |
| `street_name` | 140 | All schemas |
| `building_number` | 16 | All schemas |
| `post_code` | 16 | All schemas |
| `town_name` | 140 | All schemas |
| `address_line1` | 70 | All schemas |
| `address_line2` | 70 | All schemas |
| `department` | 70 | .09/.08+ (PostalAddress24) |
| `sub_department` | 70 | .09/.08+ |
| `building_name` | 140 | .09/.08+ |
| `floor` | 70 | .09/.08+ |
| `post_box` | 16 | .09/.08+ |
| `room` | 70 | .09/.08+ |
| `town_location_name` | 140 | .09/.08+ |
| `district_name` | 140 | .09/.08+ |
| `country_sub_division` | 35 | .09/.08+ |
| `care_of` | 140 | .13/.12 only (PostalAddress27) |
| `unit_number` | 16 | .13/.12 only |

Fields not supported by a given schema are automatically rejected during XSD validation.

---

## Charge Bearer

The `charge_bearer` attribute controls who bears the transaction charges.

| Value | Meaning |
|-------|---------|
| `SLEV` | Following Service Level (default) |
| `DEBT` | Borne by debtor |
| `CRED` | Borne by creditor |
| `SHAR` | Shared between debtor and creditor |

**EPC schemas** (`pain.001.002.03`, `pain.001.003.03`, `pain.008.002.02`, `pain.008.003.02`) only accept `SLEV`. Using another value with these schemas raises `SEPA::Error`.

**Default behavior** (when `charge_bearer` is not set):
- Credit Transfer: emits `SLEV` when `service_level` is set, nothing otherwise
- Direct Debit: always emits `SLEV`

---

## Mandate Amendments

For Direct Debit transactions, mandate amendment fields trigger `AmdmntInd = true` and generate the corresponding `AmdmntInfDtls` block:

| Attribute | Type | Purpose |
|-----------|------|---------|
| `original_mandate_id` | String (max 35) | Original mandate ID when the mandate reference changed |
| `original_debtor_account` | String (IBAN) | Original debtor IBAN when the debtor's bank account changed |
| `same_mandate_new_debtor_agent` | Boolean | Set to `true` when the debtor moved to a new bank (SMNDA) |
| `original_creditor_account` | `SEPA::CreditorAccount` | Original creditor when name or identifier changed |

These can be combined. `OrgnlMndtId` is always emitted first in the XML (per XSD sequence order).

---

## Validators

Reuse SEPA validators in your own ActiveModel classes:

```ruby
validates_with SEPA::IBANValidator                          # validates :iban
validates_with SEPA::IBANValidator, field_name: :other_iban # custom field
validates_with SEPA::BICValidator                           # validates :bic
validates_with SEPA::MandateIdentifierValidator             # validates :mandate_id
validates_with SEPA::CreditorIdentifierValidator            # validates :creditor_identifier
```

**Note:** `SEPA::IBANValidator` is strict — no spaces allowed.

---

## Supported Schemas

### Credit Transfer (pain.001)

| Schema | Type | Notes |
|--------|------|-------|
| `pain.001.001.03` | ISO generic | Default. PostalAddress6 |
| `pain.001.001.09` | ISO 2019 | PostalAddress24, BICFI, UETR |
| `pain.001.001.13` | ISO latest | PostalAddress27, BICFI, UETR |
| `pain.001.002.03` | EPC/SEPA | EUR only, BIC required, ChrgBr=SLEV only |
| `pain.001.003.03` | German DK | EUR only |
| `pain.001.001.03.ch.02` | Swiss SIX | CHF only |

### Direct Debit (pain.008)

| Schema | Type | Notes |
|--------|------|-------|
| `pain.008.001.02` | ISO generic | Default. PostalAddress6 |
| `pain.008.001.08` | ISO 2019 | PostalAddress24, BICFI, UETR, RPRE sequence type |
| `pain.008.001.12` | ISO latest | PostalAddress27, BICFI, UETR, RPRE sequence type |
| `pain.008.002.02` | EPC/SEPA | EUR only, BIC required, CORE/B2B only, ChrgBr=SLEV only |
| `pain.008.003.02` | German DK | EUR only |
