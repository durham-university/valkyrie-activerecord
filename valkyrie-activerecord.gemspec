# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "valkyrie/active_record/version"

Gem::Specification.new do |spec|
  spec.name          = "valkyrie-activerecord"
  spec.version       = Valkyrie::ActiveRecord::VERSION
  spec.authors       = ["Olli Lyytinen"]
  spec.email         = ["olli.lyytinen@durham.ac.uk"]

  spec.summary       = "Generic ActiveRecord based database backend for Valkyrie"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'valkyrie'
  spec.add_dependency 'activerecord'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "bixby"
  spec.add_development_dependency 'rubocop', '~> 0.48.0'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'database_cleaner'
end
