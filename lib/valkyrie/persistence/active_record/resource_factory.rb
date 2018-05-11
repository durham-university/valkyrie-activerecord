# frozen_string_literal: true
require 'valkyrie/persistence/active_record/orm_converter'
require 'valkyrie/persistence/active_record/resource_converter'
module Valkyrie::Persistence::ActiveRecord
  # Provides access to generic methods for converting to/from
  # {Valkyrie::Resource} and {Valkyrie::Persistence::ActiveRecord::ORM::Resource}.
  class ResourceFactory
    attr_reader :adapter
    def initialize(adapter:)
      @adapter = adapter
    end

    # @param object [Valkyrie::Persistence::ActiveRecord::ORM::Resource] AR
    #   record to be converted.
    # @return [Valkyrie::Resource] Model representation of the AR record.
    def to_resource(object:)
      ::Valkyrie::Persistence::ActiveRecord::ORMConverter.new(object, resource_factory: self).convert!
    end

    # @param resource [Valkyrie::Resource] Model to be converted to ActiveRecord.
    # @return [Valkyrie::Persistence::ActiveRecord::ORM::Resource] ActiveRecord
    #   resource for the Valkyrie resource.
    def from_resource(resource:)
      ::Valkyrie::Persistence::ActiveRecord::ResourceConverter.new(resource, resource_factory: self).convert!
    end

    # Accessor for the ActiveRecord class which all ActiveRecord resources are an
    # instance of.
    def orm_class
      ::Valkyrie::Persistence::ActiveRecord::ORM::Resource
    end
  end
end
