module OpenProject
    module CalculatedFields
      class Engine < ::Rails::Engine
        engine_name :openproject_calculated_fields
  
        include OpenProject::Plugins::ActsAsOpEngine
  
        register 'openproject-calculated-fields',
                 author_url: 'https://github.com/prgarg007',
                 bundled: false
  
        patches %i[CustomField WorkPackage]
        patch_with_namespace :BasicData, :RoleSeeder, :AdminUserSeeder
  
        add_api_endpoint 'API::V3::Root' do
          mount API::V3::CalculatedFields::CalculatedFieldsAPI
        end
  
        config.autoload_paths += Dir["#{config.root}/lib/"]
  
        initializer 'calculated_fields.register_hooks' do
          require 'openproject/calculated_fields/hooks'
        end
      end
    end
  end