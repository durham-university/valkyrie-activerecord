# frozen_string_literal: true
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'yaml'
require 'config/database_connection'
require 'active_record'

task(:default).clear
task default: [:spec]

if defined? RSpec
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end

desc 'Run RuboCop style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

task default: "bundler:audit"

Dir['./lib/tasks/*.rake'].each do |rakefile|
  import rakefile
end

namespace :db do
  task :environment do
    path = File.join(File.dirname(__FILE__), './db/migrate')
    migrations_paths = [path]
    DATABASE_ENV = ENV['RACK_ENV'] || 'test'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || migrations_paths
  end

  task configuration: :environment do
    @config = YAML.safe_load(ERB.new(File.read("db/config.yml")).result, [], [], true)[DATABASE_ENV]
  end

  task configure_connection: :configuration do
    DatabaseConnection.connect!(DATABASE_ENV)
    ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task migrate: :configure_connection do
    begin
      verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      scope   = ENV['SCOPE']
      verbose_was = ActiveRecord::Migration.verbose
      ActiveRecord::Migration.verbose = verbose
      if ActiveRecord::Migrator.respond_to?(:migrate)
        # ActiveRecord < 5.2.0
        ActiveRecord::Migrator.migrate(MIGRATIONS_DIR, version) do |migration|
          scope.blank? || scope == migration.scope
        end
      else
        # ActiveRecord >= 5.2.0
        ActiveRecord::MigrationContext.new(MIGRATIONS_DIR).migrate(version) do |migration|
          scope.blank? || scope == migration.scope
        end
      end
      ActiveRecord::Base.clear_cache!
    ensure
      ActiveRecord::Migration.verbose = verbose_was
    end
  end

  namespace :schema do
    task :load do
      Rake::Task["db:migrate"].invoke
    end
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task rollback: :configure_connection do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    if ActiveRecord::Migrator.respond_to?(:rollback)
      # ActiveRecord < 5.2.0
      ActiveRecord::Migrator.rollback(MIGRATIONS_DIR, step)
    else
      # ActiveRecord >= 5.2.0
      ActiveRecord::MigrationContext.new(MIGRATIONS_DIR).rollback(step)
    end
  end
end
