# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::ActiveRecord::QueryService do
  let(:adapter) { Valkyrie::Persistence::ActiveRecord::MetadataAdapter.new(indexed_fields: { a_member_of: { join: true } }) }

  it_behaves_like "a Valkyrie query provider"
end
