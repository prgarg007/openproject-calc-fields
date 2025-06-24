module CalculatedFields
    class FieldUpdater
      def self.update_all_work_packages
        new.update_all_work_packages
      end
  
      def self.update_for_custom_field(custom_field_id)
        new.update_for_custom_field(custom_field_id)
      end
  
      def update_all_work_packages
        CalculatedCustomField.active.find_each do |calc_field|
          update_for_custom_field(calc_field.custom_field_id)
        end
      end
  
      def update_for_custom_field(custom_field_id)
        calc_field = CalculatedCustomField.find_by(custom_field_id: custom_field_id)
        return unless calc_field&.active?
  
        WorkPackage.joins(:project)
                   .where(projects: { active: true })
                   .find_in_batches(batch_size: 100) do |work_packages|
          
          work_packages.each do |work_package|
            update_work_package_calculated_field(work_package, calc_field)
          end
        end
      end
  
      private
  
      def update_work_package_calculated_field(work_package, calc_field)
        new_value = calc_field.evaluate_for_work_package(work_package)
        current_value = work_package.custom_field_value(calc_field.custom_field)
        
        if new_value != current_value
          work_package.custom_field_values[calc_field.custom_field.id.to_s] = new_value
          work_package.save(validate: false)
        end
      rescue StandardError => e
        Rails.logger.error "Error updating calculated field for work package #{work_package.id}: #{e.message}"
      end
    end
  end
  