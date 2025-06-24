# openproject-calc-fields.gemspec
$:.push File.expand_path("../lib", __FILE__)
require_relative "lib/openproject/calculated_fields/version"

Gem::Specification.new do |s|
  s.name        = "openproject-calculated-fields"
  s.version     = "1.0"
  s.authors     = ["Pranav Garg"]
  s.email       = ["pranavgarg37@gmail.com"]
  s.homepage    = "https://github.com/prgarg007/openproject-calc-fields"
  s.summary     = 'OpenProject Calculated Fields'
  s.description = "Adds calculated fields support to OpenProject."
  s.license     = "GPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "README.md"]
  # s.add_dependency "openproject-plugins", "~> 1.0"
  
  # Add any other dependencies your plugin needs
end
