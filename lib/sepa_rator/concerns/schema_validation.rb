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
      xsd = self.class.schema_cache[profile.id]
      unless xsd
        SCHEMA_CACHE_MUTEX.synchronize do
          xsd = self.class.schema_cache[profile.id] ||=
            Nokogiri::XML::Schema(File.read(File.join(SCHEMA_DIR, profile.xsd_path)))
        end
      end

      validation_errors = xsd.validate(document)
      return if validation_errors.empty?

      sanitized = validation_errors.map { |e| e.message.gsub(/'[^']{20,}'/, "'[REDACTED]'") }
      raise SEPA::SchemaValidationError.new(
        "Incompatible with profile #{profile.id}: #{sanitized.join(', ')}",
        validation_errors.map(&:message)
      )
    end
  end
end
