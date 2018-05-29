# frozen_string_literal: true
module Valkyrie::Persistence::ActiveRecord
  # Responsible for converting a {Valkyrie::Resource} into a
  # {Valkyrie::Persistence::ActiveRecord::ORM::Resource}
  class ResourceConverter
    delegate :orm_class, :adapter, to: :resource_factory
    attr_reader :resource, :resource_factory
    def initialize(resource, resource_factory:)
      @resource = resource
      @resource_factory = resource_factory
    end

    def convert!
      orm_class.find_or_initialize_by(id: resource.id && resource.id.to_s).tap do |orm_object|
        orm_object.internal_resource = resource.internal_resource
        orm_object.metadata = orm_object.json_metadata.merge(resource.attributes.except(:id, :internal_resource, :created_at, :updated_at))

        index_fields(orm_object)
      end
    end

    private

      def index_fields(orm_object)
        new_indexed_fields = []
        adapter.indexed_fields.each do |field, info|
          val = resource.try(field.to_sym)
          next unless val.present?
          if info[:join]
            Array.wrap(val).each do |v|
              new_indexed_fields << orm_class.indexed_fields_class.new(field: field.to_s, value: v.to_s)
            end
          else
            orm_object.send(:"#{field}=", val.to_s)
          end
        end
        merge_indexed_fields(orm_object, new_indexed_fields)
      end

      def merge_indexed_fields(orm_object, new_indexed_fields)
        added = new_indexed_fields.dup
        deleted = []
        orm_object.indexed_fields.each do |f|
          existing = added.index do |f2| f2.field == f.field && f2.value == f.value end
          if existing
            added.delete_at(existing)
          else
            deleted << f
          end
        end
        
        orm_object.indexed_fields.delete(deleted) unless deleted.empty?
        orm_object.indexed_fields.concat(added) unless added.empty?
      end
  end
end
