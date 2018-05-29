# frozen_string_literal: true
require 'valkyrie/persistence/active_record/orm/indexed_field'
module Valkyrie::Persistence::ActiveRecord
  module ORM
    # ActiveRecord class for persisting data.
    # @!attribute id
    #   @return [UUID] ID of the record
    # @!attribute metadata
    #   @return [Hash] Hash of all metadata.
    # @!attribute created_at
    #   @return [DateTime] Date created
    # @!attribute updated_at
    #   @return [DateTime] Date updated
    # @!attribute internal_resource
    #   @return [String] Name of {Valkyrie::Resource} model - used for casting.
    #
    class Resource < ActiveRecord::Base

      has_and_belongs_to_many :members, -> { where( orm_indexed_fields: {field: 'member_ids'} ) },
                              join_table: "orm_indexed_fields",
                              class_name: "::Valkyrie::Persistence::ActiveRecord::ORM::Resource",
                              foreign_key: "orm_resource_id",
                              association_foreign_key: "value"

      has_and_belongs_to_many :containers, -> { where( orm_indexed_fields: {field: 'member_ids'}) },
                              join_table: "orm_indexed_fields",
                              class_name: "::Valkyrie::Persistence::ActiveRecord::ORM::Resource",
                              foreign_key: "value",
                              association_foreign_key: "orm_resource_id"

      has_many  :indexed_fields,
                dependent: :delete_all,
                class_name: "::Valkyrie::Persistence::ActiveRecord::ORM::IndexedField",
                foreign_key: "orm_resource_id"

      before_create :assign_id!

      def json_metadata
        @json_metadata ||= JSON.parse(metadata || '{}').freeze
      end

      def metadata=(value)
        value = value.to_json if value.is_a?(Hash)
        @json_metadata = nil
        super(value)
      end

      def reload
        @json_metadata = nil
        super
      end

      def self.indexed_fields_class
        ::Valkyrie::Persistence::ActiveRecord::ORM::IndexedField
      end

      def ordered_members
        return [] unless json_metadata['member_ids'].present?
        members_index = members.each_with_object({}) do |m, index|
          index[m.id.to_s] = m
        end
        json_metadata['member_ids'].map do |m_id|
          members_index[m_id['id']]
        end
      end

      def assign_id!
        self.id ||= SecureRandom.uuid
      end
    end
  end
end
