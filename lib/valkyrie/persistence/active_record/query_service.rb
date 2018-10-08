# frozen_string_literal: true
module Valkyrie::Persistence::ActiveRecord
  # Query Service for the ActiveRecord Metadata Adapter
  #
  # Most queries are delegated through to the ActiveRecord model
  # {Valkyrie::Persistence::ActiveRecord::ORM::Resource}
  #
  # @see Valkyrie::Persistence::ActiveRecord::MetadataAdapter
  class QueryService
    attr_reader :adapter
    delegate :resource_factory, to: :adapter
    delegate :orm_class, to: :resource_factory
    def initialize(adapter:)
      @adapter = adapter
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_all)
    def find_all
      orm_class.all.lazy.map do |orm_object|
        resource_factory.to_resource(object: orm_object)
      end
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_all_of_model)
    def find_all_of_model(model:)
      orm_class.where(internal_resource: model.to_s).lazy.map do |orm_object|
        resource_factory.to_resource(object: orm_object)
      end
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_by)
    def find_by(id:)
      id = Valkyrie::ID.new(id.to_s) if id.is_a?(String)
      validate_id(id)
      resource_factory.to_resource(object: orm_class.find(id.to_s))
    rescue ActiveRecord::RecordNotFound
      raise Valkyrie::Persistence::ObjectNotFoundError
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_by_alternate_identifier)
    def find_by_alternate_identifier(alternate_identifier:)
      alternate_identifier = Valkyrie::ID.new(alternate_identifier.to_s) if alternate_identifier.is_a?(String)
      validate_id(alternate_identifier)
      find_by_field(field: :alternate_ids, value: alternate_identifier.to_s) \
        .first || raise(Valkyrie::Persistence::ObjectNotFoundError)
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_many_by_ids)
    def find_many_by_ids(ids:)
      ids.map! do |id|
        id = Valkyrie::ID.new(id.to_s) if id.is_a?(String)
        validate_id(id)
        id.to_s
      end

      orm_class.where(id: ids).map do |orm_resource|
        resource_factory.to_resource(object: orm_resource)
      end
    rescue ActiveRecord::RecordNotFound
      raise Valkyrie::Persistence::ObjectNotFoundError
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_members)
    def find_members(resource:, model: nil)
      return [] if resource.id.blank?

      orm_resource = resource_factory.from_resource(resource: resource)
      members = if model
                  model = model.to_s
                  orm_resource.ordered_members.select do |member|
                    member.internal_resource == model
                  end
                else
                  orm_resource.ordered_members
                end
      members.lazy.map do |object|
        resource_factory.to_resource(object: object)
      end
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_parents)
    def find_parents(resource:)
      orm_resource = resource_factory.from_resource(resource: resource)
      orm_resource.containers.uniq.lazy.map do |object|
        resource_factory.to_resource(object: object)
      end
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_references_by)
    def find_references_by(resource:, property:)
      ids = Array.wrap(resource[property]).map(&:to_s)
      if ordered_property?(resource: resource, property: property)
        orm_objects = {}
        orm_class.where(id: ids).each do |orm_object|
          orm_objects[orm_object.id.to_s] = resource_factory.to_resource(object: orm_object)
        end
        ids.lazy.map do |id| orm_objects[id] if orm_objects.key?(id) end .reject(&:nil?)
      else
        orm_class.where(id:ids).map do |o| resource_factory.to_resource(object: o) end
      end
    end

    # (see Valkyrie::Persistence::Memory::QueryService#find_inverse_references_by)
    def find_inverse_references_by(resource:, property:)
      ensure_persisted(resource)
      returned = {}
      find_by_field(field: property, value: resource.id.to_s).reject do |o|
        next true if returned.key?(o.id)
        returned[o.id] = true
        false
      end
    end

    def find_by_field(field:, value:)
      field_info = adapter.indexed_fields[field.to_sym]
      raise ArgumentError, "Field #{field} is not indexeded. It must be set in Valkyrie::Persistence::ActiveRecord::MetadataAdapter.indexed_fields." unless field_info

      if field_info[:join]
        orm_class.indexed_fields_class.where(field: field, value: value).find_each.lazy.map do |orm_indexed_field|
          resource_factory.to_resource(object: orm_indexed_field.orm_resource)
        end
      else
        orm_class.where(field => value).find_each.lazy.map do |orm_indexed_field|
          resource_factory.to_resource(object: orm_indexed_field.orm_resource)
        end
      end
    end

    def custom_queries
      @custom_queries ||= ::Valkyrie::Persistence::CustomQueryContainer.new(query_service: self)
    end

    private

      def validate_id(id)
        raise ArgumentError, 'id must be a Valkyrie::ID' unless id.is_a? Valkyrie::ID
      end

      def ensure_persisted(resource)
        raise ArgumentError, 'resource is not saved' unless resource.persisted?
      end

      def id_type
        @id_type ||= orm_class.columns_hash["id"].type
      end

      def ordered_property?(resource:, property:)
        resource.class.schema[property].meta.try(:[], :ordered)
      end      
  end
end
