require 'gitlab/release/api_client'

module Gitlab
  module Release
    ##
    # This class contains some tools to finish a release.
    #
    class Manager < ApiClient
      ##
      # Create a new tag in the Repo.
      #
      # @param [String] tag_name Required. The name of the tag. (ex: 1.0)
      # @param [String] changelog Optional. The release notes related to the tag.
      # @option [String or Integer] project_id Optional. The id of this project, given from GitLab. Default ENV["CI_PROJECT_ID"]
      # @option [String] ref Optional. The commit SHA. Default ENV["CI_COMMIT_SHA"]
      #
      def define_tag(tag_name, changelog, options = {})
        project_id = options[:project_id] || ENV["CI_PROJECT_ID"]
        ref = options[:ref] || ENV["CI_COMMIT_SHA"]

        @client.create_tag(project_id, tag_name, ref, '', changelog)
      end

      ##
      # Close all the milestones containing the version name.
      #
      # @param [String] version_name Required. The name of the version. (ex: 1.0)
      # @option [String or Integer] project_id Optional. The id of this project, given from GitLab. Default ENV["CI_PROJECT_ID"]
      #
      def close_milestones(version_name, options = {})
        project_id = options[:project_id] || ENV["CI_PROJECT_ID"]

        select_milestones(project_id, version_name).each do |milestone|
          @client.edit_milestone(project_id, milestone.id, state_event: 'close')
        end
      end
    end
  end
end