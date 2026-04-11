# frozen_string_literal: true

module SEPA
  module Builders
    Context = Data.define(:message, :profile, :builder, :transaction, :group)

    class Stage
      def self.call(context)
        new(context).call
      end

      def initialize(context)
        @context = context
      end

      def call
        raise NotImplementedError, "#{self.class} must implement #call"
      end

      private

      attr_reader :context

      def builder = context.builder
      def profile = context.profile
      def transaction = context.transaction
      def group = context.group
      def message = context.message
    end
  end
end
