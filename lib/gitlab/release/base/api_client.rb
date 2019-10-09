require 'gitlab'

module Gitlab
  module Release
    module Base
      class ApiClient
        # @param [String] endpoint API endpoint URL, default: ENV['GITLAB_API_ENDPOINT'] and falls back to ENV['CI_API_V4_URL']
        # @param [String] private_token user's private token or OAuth2 access token, default: ENV['GITLAB_API_PRIVATE_TOKEN']
        def initialize(endpoint, private_token)
          @client = Gitlab.client(
              endpoint: endpoint,
              private_token: private_token
          )
        end

        # @param [String or Integer] project_id
        # @param [String] version_name
        # @return Array
        def select_milestones(project_id, version_name)
          @client.milestones(project_id).select do |milestone|
            milestone.title.include?(version_name) || milestone.description.include?(version_name)
          end
        end
      end
    end
  end
end