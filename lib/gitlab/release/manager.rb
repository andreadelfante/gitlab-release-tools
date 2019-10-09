require 'gitlab/release/api_client'

module Gitlab
  module Release
    class Manager < ApiClient
      # @param [String] tag_name
      # @param [String] changelog
      # @param [String or Integer] project_id default ENV["CI_PROJECT_ID"]
      # @param [String] ref default ENV["CI_COMMIT_SHA"]
      def define_tag(tag_name, changelog, params = {})
        project_id = params[:project_id] || ENV["CI_PROJECT_ID"]
        ref = params[:ref] || ENV["CI_COMMIT_SHA"]

        @client.create_tag(project_id, tag_name, ref, '', changelog)
      end

      # @param [String] version_name
      # @param [String or Integer] project_id default ENV["CI_PROJECT_ID"]
      def close_milestones(version_name, params = {})
        project_id = params[:project_id] || ENV["CI_PROJECT_ID"]

        select_milestones(project_id, version_name).each do |milestone|
          @client.edit_milestone(project_id, milestone.id, state_event: 'close')
        end
      end
    end
  end
end