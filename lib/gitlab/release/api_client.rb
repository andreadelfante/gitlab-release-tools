require 'gitlab'

module Gitlab
  module Release
    class ApiClient
      def initialize(options = {})
        @client = Gitlab.client(
            endpoint: options[:endpoint],
            private_token: options[:private_token]
        )
      end

      # @param [String] version_name
      # @return Array
      protected def select_milestones(project_id, version_name)
        @client.milestones(project_id).select do |milestone|
          milestone.title.include?(version_name) || milestone.description.include?(version_name)
        end
      end
    end
  end
end