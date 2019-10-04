require 'gitlab/changelog/version'
require 'gitlab/changelog/formatter'
require 'gitlab'

module Gitlab
  module Changelog
    class Generator
      # @param [String] endpoint API endpoint URL, default: ENV['GITLAB_API_ENDPOINT'] and falls back to ENV['CI_API_V4_URL']
      # @param [String] private_token user's private token or OAuth2 access token, default: ENV['GITLAB_API_PRIVATE_TOKEN']
      # @param [Formatter] formatter
      # @param [Integer] max_iterations_merge_requests
      # @param [Integer] max_iterations_issues
      def initialize(params = {})
        @formatter = params[:formatter] || Formatter.new
        @max_iterations_merge_requests = params[:max_iterations_merge_requests] || 1000
        @max_iterations_issues = params[:max_iterations_issues] || 1000
        endpoint = params[:endpoint]
        private_token = params[:private_token]

        @client = Gitlab.client(
            endpoint: endpoint,
            private_token: private_token
        )
      end

      # @param [String] version_name required
      # @param [Integer, String] project_id default: ENV['CI_PROJECT_ID']
      # @param [TrueClass or FalseClass] include_mrs
      # @param [TrueClass or FalseClass] mr_reference
      # @param [TrueClass or FalseClass] include_issues
      # @param [TrueClass or FalseClass] issue_reference
      # @param [AllCriteria] mr_criteria
      # @param [AllCriteria] issue_criteria
      # @return [Array[String]]
      def changelog(version_name, params = {})
        project_id        = params[:project_id]       || ENV["CI_PROJECT_ID"]
        include_mrs       = params[:include_mrs]      || true
        include_issues    = params[:include_issues]   || false
        mr_reference      = params[:mr_reference]     || true
        issue_reference   = params[:issue_reference]  || true

        results = []
        if include_mrs
          results += changelog_from_merge_requests(project_id, version_name, mr_reference)
        end
        if include_issues
          results += changelog_from_issues(project_id, version_name, issue_reference)
        end
        results
      end

      private def changelog_from_merge_requests(project_id, version_name, with_reference)
        results = []
        select_milestones(project_id, version_name).each do |milestone|
          i = 0
          all = false
          while i < @max_iterations_merge_requests and !all
            merge_requests = @client.milestone_merge_requests(project_id, milestone.id, {page: i})

            if merge_requests.empty?
              all = true
            else
              merge_requests.each do |mr|
                results.push(@formatter.format_merge_request(mr, with_reference))
              end

              i += 1
            end
          end
        end
        results
      end

      private def changelog_from_issues(project_id, version_name, with_reference)
        results = []
        select_milestones(project_id, version_name).each do |milestone|
          i = 0
          all = false
          while i < @max_iterations_issues and !all
            issues = @client.milestone_issues(project_id, milestone.id, {page: i})

            if issues.empty?
              all = true
            else
              issues.each do |issue|
                results.push(@formatter.format_issue(issue, with_reference))
              end

              i += 1
            end
          end
        end
        results
      end

      private def select_milestones(project_id, version_name)
        @client.milestones(project_id).select do |milestone|
          milestone.title.include?(version_name) || milestone.description.include?(version_name)
        end
      end
    end
  end
end

