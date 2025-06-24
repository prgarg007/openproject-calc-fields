class AddFormulaToCustomFields < ActiveRecord::Migration[7.0]
    def change
      add_column :custom_fields, :is_calculated, :boolean, default: false
      add_column :custom_fields, :calculation_formula, :text
      add_column :custom_fields, :formula_output_type, :string
      
      add_index :custom_fields, :is_calculated
    end
  end