module SEPA
  class Error < RuntimeError; end
  class ValidationError < Error; end
  class SchemaValidationError < Error; end
end
