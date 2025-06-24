module OpenProject::CalculatedFields::Patches
    module CustomFieldPatch
      def self.included(base)
        base.has_one :calculated_custom_field, dependent: :destroy
        
        base.scope :calculated, -> { where(is_calculated: true) }
        base.scope :not_calculated, -> { where(is_calculated: false) }
      end
    end
  end