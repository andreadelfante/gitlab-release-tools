# gitlab-release-tools
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/andreadelfante/gitlab-release-tools/blob/master/LICENSE)
[![Gem](https://img.shields.io/gem/v/gitlab-release-tools.svg?style=flat)](https://rubygems.org/gems/gitlab-release-tools)
[![Build Status](https://travis-ci.org/andreadelfante/gitlab-release-tools.svg?branch=master)](https://travis-ci.org/andreadelfante/gitlab-release-tools)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gitlab-release-tools'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install gitlab-release-tools

## Usage

```ruby
endpoint = 'endpoint' # or value from ENV for CI/CD
private_token = 'private_token' # or value from ENV for CI/CD
project_id = 50 # or value from ENV for CI/CD
version = '1.0'

generator = Gitlab::Release::Changelog::Generator.new(endpoint: endpoint, private_token: private_token)
changelog = generator.changelog(version, project_id: project_id)
# print(changelog) for a simple changelog list
# print(changelog.to_s_with_reference) for a changelog list with mrs/issues references 

manager = Gitlab::Release::Manager.new(endpoint: endpoint, private_token: private_token)
manager.define_tag(version, changelog.to_s_with_reference)
manager.close_milestones(version)
```

Check out the [documentation](https://andreadelfante.github.io/gitlab-release-tools/) for more.

## Development

1. Install this gem onto your local machine, `bundle exec rake install`.
2. Copy `.env.example` and rename with `.env`.
3. Define Gitlab base url and generate a private token. 
4. You are ready to go!

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

