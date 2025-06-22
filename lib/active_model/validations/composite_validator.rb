require 'active_model/validations'

module ActiveModel
  module Validations
    # Composite Validator. Inherits from ActiveModel::EachValidator.
    #
    # Usage:
    #   class UserRegistration
    #     include ActiveModel::Validations
    #
    #     attr_accessor :user, :user_credentials
    #
    #     validates :user, composite: true
    #     validates :user_credentials, composite: true
    #   end
    class CompositeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        Validator
          .call(parent: self, record: record, attribute: attribute, value: value)
      end

      class Validator
        private_class_method :new

        class << self
          def call(parent:, record:, attribute:, value:)
            new(
              parent: parent, record: record, attribute: attribute, value: value
            ).call
          end
        end

        def initialize(parent:, record:, attribute:, value:)
          @parent = parent
          @record = record
          @attribute = attribute
          @value = value
        end

        def call
          return if value.nil? || valid?

          add_error!
        end

        private

        attr_reader :parent, :record, :attribute, :value

        delegate :options, to: :parent

        def associations
          @associations ||= \
            if value.class.include?(Enumerable) && !value.is_a?(Struct)
              value
            else
              [value]
            end.select { _1.respond_to?(:valid?) }
        end

        def valid?
          invalid_associations.empty?
        end

        def invalid_associations
          @invalid_associations ||= \
            associations.select { _1.invalid?(context) }
        end

        def invalid_message
          invalid_associations
            .map { _1.errors.full_messages.to_sentence }
            .to_sentence
        end

        def context = options.try(:[], :context)

        def add_error!
          record
            .errors
            .add(
              attribute,
              :invalid_association,
              association: invalid_message
            )
        end
      end
      private_constant :Validator
    end
  end
end
