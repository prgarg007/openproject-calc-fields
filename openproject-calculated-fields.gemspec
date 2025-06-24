# openproject-calc-fields.gemspec
$:.push File.expand_path("../lib", __FILE__)
require 'open_project/calc_fields/version'

Gem::Specification.new do |s|
  s.name        = "openproject-calc-fields"
  s.version     = OpenProject::CalcFields::VERSION
  s.authors     = ["Pranav Garg"]
  s.email       = ["pranavgarg37@gmail.com"]
  s.homepage    = "https://github.com/prgarg007/openproject-calc-fields"
  s.summary     = 'OpenProject Calculated Fields'
  s.description = "Adds calculated fields support to OpenProject."
  s.license     = "GPLv3"

  s.files = Dir["{app,config,db,lib}/**/*", "README.md"]
  s.add_dependency "openproject-plugins", "~> 1.0"
  
  # Add any other dependencies your plugin needs
end