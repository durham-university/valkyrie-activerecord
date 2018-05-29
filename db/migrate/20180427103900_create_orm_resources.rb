# frozen_string_literal: true
class CreateOrmResources < ActiveRecord::Migration[5.0]
  def change
    create_table :orm_resources, id: :string do |t|
      t.text :metadata, null: false, limit: 1_073_741_823
      t.string :internal_resource, index: true
      t.timestamps
    end

    create_table :orm_indexed_fields do |t|
      t.string :orm_resource_id, null: false, index: true
      t.string :field
      t.string :value
    end

    add_index :orm_resources, :updated_at
    add_index :orm_indexed_fields, [:field, :value]
  end
end
