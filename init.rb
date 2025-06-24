require 'openproject-calculated-fields'

Redmine::Plugin.register :openproject_calculated_fields do
  name 'OpenProject Calculated Fields'
  author 'Plugin Author'
  description 'Adds support for calculated custom fields in OpenProject Community Edition'
  version OpenProject::CalculatedFields::VERSION
  url 'https://github.com/example/openproject-calculated-fields'
  author_url 'https://github.com/example'

  requires_openproject '>= 13.0.0'

  menu :admin_menu, :calculated_custom_fields,
       { controller: 'admin/calculated_custom_fields', action: 'index' },
       caption: :label_calculated_custom_fields,
       after: :custom_fields,
       if: Proc.new { User.current.admin? }

  settings default: {
    'max_formula_length' => 500,
    'allowed_functions' => %w[CONCAT IF LOWER UPPER LEN TRIM LEFT RIGHT MID]
  }, partial: 'settings/calculated_fields'
end