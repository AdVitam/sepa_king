# frozen_string_literal: true

module SEPA
  class Error < RuntimeError; end
  class ValidationError < Error; end

  # Raised when `Message.new(country:)` is called with a symbol that isn't a
  # recognized SEPA country code. Catches typos like `:fre` instead of `:fr`,
  # which would otherwise silently fall back to the generic EPC profile.
  class UnknownCountryError < Error
    attr_reader :country, :known_countries

    def initialize(country:, known_countries:)
      @country = country
      @known_countries = known_countries
      super("Unknown country #{country.inspect}. Known SEPA countries: " \
            "#{known_countries.sort.inspect}. Pass `country: nil` to use the generic SEPA profile.")
    end
  end

  # Raised when `Message.new(country:, version:)` is called with a version the
  # requested country doesn't support. Carries the list of available versions
  # so callers can recover or surface a helpful message.
  class UnsupportedVersionError < Error
    attr_reader :country, :version, :available_versions, :fallback_used

    def initialize(country:, version:, available_versions:, fallback_used: false)
      @country = country
      @version = version
      @available_versions = available_versions.dup.freeze
      @fallback_used = fallback_used

      scope = fallback_used ? "generic SEPA versions (no dedicated profile for #{country.inspect})" : "country=#{country.inspect}"
      super("Version #{version.inspect} not supported for #{scope}. Available: #{@available_versions.inspect}")
    end
  end

  class SchemaValidationError < Error
    attr_reader :validation_errors

    def initialize(message, validation_errors = [])
      @validation_errors = validation_errors
      super(message)
    end
  end
end
