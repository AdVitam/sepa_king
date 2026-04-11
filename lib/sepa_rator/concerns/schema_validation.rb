# frozen_string_literal: true

require 'active_support/concern'

module SEPA
  module SchemaValidation
    extend ActiveSupport::Concern

    SCHEMA_DIR = File.expand_path('../../schema', __dir__).freeze
    SCHEMA_CACHE_MUTEX = Mutex.new

    class_methods do
      def schema_cache
        @schema_cache ||= {}
      end
    end

    private

    def validate_final_document!(document, profile)
      xsd = load_xsd(profile)

      validation_errors = xsd.validate(document)
      return if validation_errors.empty?

      sanitized = validation_errors.map { |e| e.message.gsub(/'[^']{20,}'/, "'[REDACTED]'") }
      raise SEPA::SchemaValidationError.new(
        "Incompatible with profile #{profile.id}: #{sanitized.join(', ')}",
        validation_errors.map(&:message)
      )
    end

    # Keyed by `profile.xsd_path` so two profiles that share an ISO schema
    # name but point to different XSD files (e.g. the ISO baseline and the
    # DK GBIC5 variant) never share a cache entry.
    def load_xsd(profile)
      cache_key = profile.xsd_path
      cached = self.class.schema_cache[cache_key]
      return cached if cached

      SCHEMA_CACHE_MUTEX.synchronize do
        self.class.schema_cache[cache_key] ||= read_xsd(profile)
      end
    end

    def read_xsd(profile)
      path = File.join(SCHEMA_DIR, profile.xsd_path)
      Nokogiri::XML::Schema(File.read(path))
    rescue Errno::ENOENT => e
      raise SEPA::Error,
            "[#{profile.id}] XSD file not found at #{path} (xsd_path=#{profile.xsd_path.inspect}): #{e.message}"
    end
  end
end
