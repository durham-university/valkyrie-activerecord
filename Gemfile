# frozen_string_literal: true
source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

gem 'valkyrie', github: 'samvera-labs/valkyrie' if ENV['EDGE_VALKYRIE']
