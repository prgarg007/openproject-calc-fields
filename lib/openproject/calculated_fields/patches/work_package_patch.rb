module OpenProject::CalculatedFields::Patches
    module WorkPackagePatch
      def self.included(base)
        base.include WorkPackageCalculatedFields
      end
    end
  end