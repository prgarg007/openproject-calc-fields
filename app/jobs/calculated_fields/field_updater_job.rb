module CalculatedFields
    class FieldUpdaterJob < ApplicationJob
      queue_as :default
  
      def perform(custom_field_id)
        CalculatedFields::FieldUpdater.update_for_custom_field(custom_field_id)
      end
    end
  end
  