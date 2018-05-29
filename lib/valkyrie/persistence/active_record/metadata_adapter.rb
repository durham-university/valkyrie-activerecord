# frozen_string_literal: true
module Valkyrie::Persistence::ActiveRecord
  # Metadata Adapter for ActiveRecord
  #
  # This adapter uses ActiveRecord to persist resources in a generic database. In particular,
  # the database does not need to support any JSON features.
  #
  class MetadataAdapter
    attr_reader :config

    def initialize(config = {})
      @config = config
    end

    # @return [Class] {Valkyrie::Persistence::ActiveRecord::Persister}
    def persister
      Valkyrie::Persistence::ActiveRecord::Persister.new(adapter: self)
    end

    # @return [Class] {Valkyrie::Persistence::ActiveRecord::QueryService}
    def query_service
      @query_service ||= Valkyrie::Persistence::ActiveRecord::QueryService.new(adapter: self)
    end

    # @return [Class] {Valkyrie::Persistence::ActiveRecord::ResourceFactory}
    def resource_factory
      @resource_factory ||= Valkyrie::Persistence::ActiveRecord::ResourceFactory.new(adapter: self)
    end

    # Information about additional fields that need to be indexed
    # @return [Hash]
    def indexed_fields
      @indexed_fields ||= { 
        member_ids: { join: true },
        alternate_ids: { join: true }
      }.merge(config.fetch(:indexed_fields, {}))
    end
  end
end
