# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# The API framework-related gems
gem "grape", "~> 2.4"
gem "grape-entity", "~> 1.0"
gem "grape-swagger"
gem "grape-swagger-entity"

gem "falcon" # The app server

gem "async-rest" # Used for making requests towards other servers

group :development, :test do
  gem "dotenv" # Used to load environment variables from .env files

  gem "rerun", require: false # Used to reload the server when code changes

  gem "debug" # Used for calling debugger from the code

  # Code formatting and hooks
  gem "lefthook", require: false # Used to make git hooks available between dev machines
  gem "pronto", "~> 0.11", require: false # pronto analyzes code on changed code only
  gem "pronto-rubocop", require: false # pronto-rubocop extends pronto for rubocop

  gem "rubocop", require: false # A static code analyzer and formatter
  gem "rubocop-minitest", require: false # A rubocop extension for minitest
  gem "rubocop-performance", require: false # A rubocop extension with performance suggestions
  gem "rubocop-yard", require: false # A rubocop extension for yard documentation
end

group :test do
  gem "minitest" # The test framework
  gem "minitest-hooks", require: "minitest/hooks/default" # Adds before(:all) hooks to improve test time
  gem "rack-test" # Adds functionality to test Rack apps
end
