# frozen_string_literal: true
module Valkyrie::Persistence::ActiveRecord
  # Responsible for converting a
  # {Valkyrie::Persistence::ActiveRecord::ORM::Resource} to a {Valkyrie::Resource}
  class ORMConverter
    delegate :adapter, to: :resource_factory
    attr_reader :orm_object, :resource_factory

    def initialize(orm_object, resource_factory:)
      @orm_object = orm_object
      @resource_factory = resource_factory
    end

    # Create a new instance of the class described in attributes[:internal_resource]
    # and send it all the attributes that @orm_object has
    def convert!
      @resource ||= resource
    end

    private

      def resource
        resource_klass.new(
          attributes.merge(
            new_record: false,
            Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => lock_token
          )
        )
      end

      def lock_token
        return lock_token_warning unless orm_object.class.column_names.include?("lock_version")
        @lock_token ||=
          Valkyrie::Persistence::OptimisticLockToken.new(
            adapter_id: resource_factory.adapter_id,
            token: orm_object.lock_version
          )
      end

      def lock_token_warning
        return nil unless resource_klass.optimistic_locking_enabled?
        warn "[MIGRATION REQUIRED] You have loaded a resource from the ActiveRecord adapter with " \
             "optimistic locking enabled, but the necessary migrations have not been run. \n" \
             "Please run `bin/rails valkyrie_active_record_engine:install:migrations && bin/rails db:migrate` " \
             "to enable this feature for ActiveRecord."
        nil
      end

      def resource_klass
        internal_resource.constantize
      end

      def internal_resource
        orm_object.internal_resource
      end

      # @return [Hash] Valkyrie-style hash of attributes.
      def attributes
        @attributes ||= orm_object.attributes.merge(rdf_metadata).symbolize_keys
      end

      def rdf_metadata
        @rdf_metadata ||= ::Valkyrie::Persistence::Postgres::ORMConverter::RDFMetadata.new(orm_object.json_metadata).result
      end
  end
end
