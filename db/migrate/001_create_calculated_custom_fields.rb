class CreateCalculatedCustomFields < ActiveRecord::Migration[7.0]
    def change
      create_table :calculated_custom_fields do |t|
        t.references :custom_field, null: false, foreign_key: true, index: true
        t.text :formula, null: false
        t.text :parsed_formula
        t.json :referenced_fields, default: []
        t.string :output_type, null: false, default: 'text'
        t.boolean :active, default: true
        t.timestamps
      end
  
      add_index :calculated_custom_fields, :active
      add_index :calculated_custom_fields, :output_type
    end
  end