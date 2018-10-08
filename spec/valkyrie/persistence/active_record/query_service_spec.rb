# frozen_string_literal: true
require 'spec_helper'
require 'valkyrie/specs/shared_specs'

RSpec.describe Valkyrie::Persistence::ActiveRecord::QueryService do
  let(:adapter) { Valkyrie::Persistence::ActiveRecord::MetadataAdapter.new(indexed_fields: { a_member_of: { join: true }, an_ordered_member_of: { join: true } }) }

  it_behaves_like "a Valkyrie query provider"

  describe "implementation" do
    let(:query_service) { adapter.query_service }
    let(:persister) { adapter.persister }

    before {
      class CustomResource < Valkyrie::Resource
        attribute :alternate_ids, Valkyrie::Types::Array
        attribute :title
        attribute :member_ids, Valkyrie::Types::Array
        attribute :a_member_of
      end
    }
    after {
      Object.send(:remove_const, :CustomResource)
    }
      
    let!(:members) { 
      Array.new(5) do |i| 
        persister.save(resource: CustomResource.new(title: "test #{i}"))
      end 
    }
    # NOTE: parent has the id of other_resource as its alternate_id. This is to test that
    # member and alternate ids are indexed and queried correctly and don't get mixed up.
    let!(:other_parent) { persister.save(resource: CustomResource.new(title: "other parent", member_ids: [other_resource.id])) }
    let!(:other_resource) { persister.save(resource: CustomResource.new(title: "other")) }
    let!(:parent) { persister.save(resource: CustomResource.new(title: "parent", member_ids: members.map(&:id), alternate_ids: [other_resource.id])) }

    describe "#find_members" do
      it "finds members and only members" do
        queried_members = query_service.find_members(resource: parent)
        expect(queried_members.map(&:id)).to match_array(members.map(&:id))
      end
    end

    describe "#find_parents" do
      it "finds the correct parents" do
        queried_parents = query_service.find_parents(resource: members[0])
        expect(queried_parents.map(&:id)).to match_array([parent.id])
        queried_other_parents = query_service.find_parents(resource: other_resource)
        expect(queried_other_parents.map(&:id)).to match_array([other_parent.id])
      end
    end

    describe "#find_by_alternate_identifier" do
      it "finds the resource" do
        queried_resource = query_service.find_by_alternate_identifier(alternate_identifier: other_resource.id)
        expect(queried_resource.id).to eql(parent.id)
      end
    end
  end
end
