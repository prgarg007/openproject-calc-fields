module WorkPackageCalculatedFields
    extend ActiveSupport::Concern
  
    included do
      after_save :update_calculated_custom_fields
      after_update :update_dependent_calculated_fields
    end
  
    private
  
    def update_calculated_custom_fields
      calculated_fields = CalculatedCustomField.joins(:custom_field)
                                             .where(custom_fields: { type: 'WorkPackageCustomField' })
                                             .active
  
      calculated_fields.each do |calc_field|
        new_value = calc_field.evaluate_for_work_package(self)
        current_value = custom_field_value(calc_field.custom_field)
        
        if new_value != current_value
          custom_field_values[calc_field.custom_field.id.to_s] = new_value
        end
      end
    end
  
    def update_dependent_calculated_fields
      return unless saved_changes.any?
      
      # Find calculated fields that reference changed fields
      changed_field_names = saved_changes.keys.map do |key|
        case key
        when /^custom_field_(\d+)$/
          "cf_#{$1}"
        else
          key
        end
      end
  
      dependent_fields = CalculatedCustomField.active
                                            .select { |cf| (cf.referenced_fields & changed_field_names).any? }
  
      dependent_fields.each do |calc_field|
        new_value = calc_field.evaluate_for_work_package(self)
        self.custom_field_values[calc_field.custom_field.id.to_s] = new_value
      end
  
      save if dependent_fields.any?
    end
  end