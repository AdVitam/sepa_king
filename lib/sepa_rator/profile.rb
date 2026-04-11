# frozen_string_literal: true

module SEPA
  ProfileFeatures = Data.define(
    :bic_tag,
    :wrap_date,
    :requires_bic,
    :org_bic_tag,
    :instr_for_dbtr_agt_format,
    # `:instruction3_code` (ISO enum) or `:external_code` (free 1-4 char, v13+)
    :instr_for_cdtr_agt_code_type,
    :regulatory_reporting_version,
    :charset,
    :min_amount,
    :requires_structured_address,
    :requires_country_code_on_address,
    :extras
  ) do
    def self.default
      new(
        bic_tag: :BICFI,
        wrap_date: true,
        requires_bic: false,
        org_bic_tag: :AnyBIC,
        instr_for_dbtr_agt_format: :text,
        instr_for_cdtr_agt_code_type: :instruction3_code,
        regulatory_reporting_version: :v3,
        charset: :iso_latin,
        min_amount: nil,
        requires_structured_address: false,
        requires_country_code_on_address: false,
        extras: {}.freeze
      )
    end

    def [](key)
      respond_to?(key) ? public_send(key) : extras[key]
    end

    def merge(**overrides)
      extras_override = overrides.delete(:extras) || {}
      merged_extras = extras.merge(extras_override).freeze
      self.class.new(**to_h, **overrides, extras: merged_extras)
    end
  end

  module StageList
    module_function

    def merge(old, operation)
      return Array(operation).freeze if operation.is_a?(Array)

      case operation
      in { replace: klass, with: replacement }
        old.map { |stage| stage == klass ? replacement : stage }.freeze
      in { insert_after: klass, stage: stage }
        old.flat_map { |existing| existing == klass ? [existing, stage] : [existing] }.freeze
      in { insert_before: klass, stage: stage }
        old.flat_map { |existing| existing == klass ? [stage, existing] : [existing] }.freeze
      in { remove: klass }
        old.reject { |stage| stage == klass }.freeze
      end
    end
  end

  Profile = Data.define(
    :id,
    :family,
    :iso_schema,
    :xsd_path,
    :namespace,
    :features,
    :validators,
    :capabilities,
    :transaction_stages,
    :payment_info_stages,
    :group_header_stages,
    :accept_transaction
  ) do
    def supports?(capability)
      capabilities.include?(capability)
    end

    def accepts?(transaction)
      accept_transaction.nil? || accept_transaction.call(transaction, self)
    end

    def with(**overrides)
      merged = overrides.each_with_object(to_h.dup) do |(key, value), acc|
        acc[key] = merge_field(key, acc[key], value)
      end
      self.class.new(**merged)
    end

    private

    def merge_field(key, old, value)
      case key
      when :features
        old.merge(**value)
      when :validators
        merge_list(old, value, unique: false)
      when :capabilities
        merge_list(old, value, unique: true)
      when :transaction_stages, :payment_info_stages, :group_header_stages
        StageList.merge(old, value)
      else
        value
      end
    end

    # Merge helper for the flat list fields (`validators`, `capabilities`).
    #
    # - A raw Array is appended to the parent list (most common case — a
    #   child profile extends its parent with more rules).
    # - `{ replace: [...] }` drops the parent list and uses the new one —
    #   required by tightened profiles like EPC AOS that need a stricter
    #   set than their ISO parent.
    # - `{ add: [...] }` is a more explicit synonym for "append".
    def merge_list(old, value, unique:)
      case value
      when Array
        combined = old + value
      when Hash
        case value
        in { replace: new }
          combined = Array(new)
        in { add: new }
          combined = old + Array(new)
        end
      end
      (unique ? combined.uniq : combined).freeze
    end
  end

  class ProfileRegistry
    @profiles = {}
    # Nested map: { family => { country_symbol_or_nil => { version_symbol => profile } } }
    @country_defaults = {}

    class << self
      def register(profile, aliases: [])
        @profiles[profile.id] = profile
        aliases.each { |name| @profiles[name.to_s] = profile }
        profile
      end

      def [](profile_id)
        @profiles.fetch(profile_id.to_s) do
          raise ArgumentError, "Unknown profile: #{profile_id.inspect}"
        end
      end

      def all
        @profiles.values.uniq
      end

      # Register a (family, country, version) → profile mapping used by
      # `Message.new(country:, version:)` to resolve the recommended profile.
      def set_country_default(family:, country:, version:, profile:)
        @country_defaults[family] ||= {}
        @country_defaults[family][country] ||= {}
        @country_defaults[family][country][version] = profile
      end

      # Resolve a (family, country, version) triple to the recommended profile.
      # Falls back to the generic `country: nil` entry when the requested
      # country has no specific profiles registered.
      #
      # @raise [ArgumentError] when the family is unknown
      # @raise [SEPA::UnsupportedVersionError] when the version is unknown for
      #   the resolved country
      def recommended(family:, country: nil, version: :latest)
        per_country = @country_defaults.fetch(family) do
          raise ArgumentError, "Unknown family: #{family.inspect}"
        end

        versions = per_country[country] || per_country[nil]
        raise ArgumentError, "No default profiles registered for family=#{family.inspect}" unless versions

        versions.fetch(version) do
          raise SEPA::UnsupportedVersionError.new(
            country: country, version: version,
            available_versions: versions.keys
          )
        end
      end
    end
  end
end
