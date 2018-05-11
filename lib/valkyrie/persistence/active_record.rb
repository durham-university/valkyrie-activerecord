# frozen_string_literal: true
#
module Valkyrie::Persistence
  # Implements the DataMapper Pattern to store metadata with ActiveRecord
  module ActiveRecord
    require 'valkyrie/persistence/active_record/metadata_adapter'
    require 'valkyrie/persistence/active_record/persister'
    require 'valkyrie/persistence/active_record/query_service'
  end
end
