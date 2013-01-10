# -*- encoding: utf-8 -*-

$:.unshift File.expand_path("../lib", __FILE__)
require "salesforce_bulk/version"

Gem::Specification.new do |s|
  s.name        = "salesforce_bulk"
  s.version     = SalesforceBulk::VERSION
  s.authors     = ["Jorge Valdivia", "Arne Brasseur"]
  s.email       = ["jorge@valdivia.me", "arne@arnebrasseur.net"]
  s.homepage    = "https://github.com/arnebrasseur/salesforce_bulk"

  s.summary     = %q{Ruby support for the Salesforce Bulk API}
  s.description = %q{This gem provides a super simple interface for the Salesforce Bulk API. It provides support for insert, update, upsert, delete, and query.}

  s.rubyforge_project = "salesforce_bulk"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"

  s.add_dependency "httparty"
end
