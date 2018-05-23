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
        orm_object.member_ids = resource.member_ids.try(:map, &:to_s) if orm_object.respond_to?(:member_ids=) && resource.respond_to?(:member_ids)

        index_fields(orm_object)
      end
    end

    private

      def index_fields(orm_object)
        orm_object.indexed_fields.clear
        adapter.indexed_fields.each do |field, info|
          val = resource.try(field.to_sym)
          next unless val.present?
          if info[:join]
            Array.wrap(val).each do |v|
              orm_object.indexed_fields << orm_class.indexed_fields_class.new(field: field.to_s, value: v.to_s)
            end
          else
            orm_object.send(:"#{field}=", val.to_s)
          end
        end
      end
  end
end
