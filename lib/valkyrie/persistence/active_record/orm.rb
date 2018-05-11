# frozen_string_literal: true
require 'valkyrie/persistence/active_record/orm/resource'
module Valkyrie::Persistence::ActiveRecord
  # Namespace for ActiveRecord access.
  module ORM
    def self.table_name_prefix
      'orm_'
    end
  end
end
