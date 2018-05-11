# frozen_string_literal: true
module Valkyrie::Persistence::ActiveRecord
  module ORM
    # Class for storing indexed values in the database. This is essentially
    # subject-predicate-object style table. These values are also stored in
    # the resource json. This table is really only to enable indexing.
    #
    # @!attribute id
    #   @return [UUID] ID of the record
    # @!attribute field
    #   @return [String] The field name
    # @!attribute value
    #   @return [String] The alternate identifier
    #
    class IndexedField < ActiveRecord::Base
      belongs_to  :orm_resource,
                  inverse_of: :indexed_fields,
                  class_name: "::Valkyrie::Persistence::ActiveRecord::ORM::Resource"
    end
  end
end
