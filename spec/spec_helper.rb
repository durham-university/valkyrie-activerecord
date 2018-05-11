# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'
ENV['RAILS_ENV'] = 'test'
require 'simplecov'
require 'coveralls'
Coveralls.wear!
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
)
SimpleCov.start do
  add_filter 'spec'
  add_filter 'vendor'
end
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'valkyrie/activerecord'
require 'pry'

ROOT_PATH = Pathname.new(Dir.pwd)
Dir[Pathname.new("./").join("spec", "support", "**", "*.rb")].sort.each { |file| require_relative file.gsub(/^spec\//, "") }
