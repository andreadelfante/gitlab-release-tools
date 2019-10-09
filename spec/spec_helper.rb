require "bundler/setup"
require 'rspec'
require 'webmock/rspec'
require 'gitlab'

ENDPOINT = 'https://api.example.com'
PRIVATE_TOKEN = 'secret'
PROJECT_ID = 3
COMMIT_SHA = "b55be4dc5c052fb0058ef1ea96acd5e4e37f1bed"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    Gitlab.endpoint = ENDPOINT
    Gitlab.private_token = PRIVATE_TOKEN

    stub_get("/projects/#{PROJECT_ID}/milestones", 'milestones')
  end
end

def load_fixture(name)
  File.new(File.dirname(__FILE__) + "/fixtures/#{name}.json")
end

%i[get post put delete].each do |method|
  define_method "stub_#{method}" do |path, fixture, status_code = 200|
    stub_request(method, "#{ENDPOINT}#{path}")
        .with(headers: {'PRIVATE-TOKEN' => PRIVATE_TOKEN})
        .to_return(body: load_fixture(fixture), status: status_code)
  end

  define_method "a_#{method}" do |path|
    a_request(method, "#{ENDPOINT}#{path}")
        .with(headers: { 'PRIVATE-TOKEN' => PRIVATE_TOKEN })
  end
end