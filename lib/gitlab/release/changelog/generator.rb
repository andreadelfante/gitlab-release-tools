require 'gitlab/release/api_client'
require 'gitlab/release/changelog/entries'
require 'gitlab/release/changelog/entry'
require 'gitlab/release/version'

module Gitlab
  module Release
    module Changelog
      class Generator < ApiClient
        # @param [String] endpoint API endpoint URL, default: ENV['GITLAB_API_ENDPOINT'] and falls back to ENV['CI_API_V4_URL']
        # @param [String] private_token user's private token or OAuth2 access token, default: ENV['GITLAB_API_PRIVATE_TOKEN']
        # @param [Integer] max_loop_mrs
        # @param [Integer] max_loop_issues
        def initialize(endpoint, private_token, max_loop_mrs = 1000, max_loop_issues = 1000)
          @max_loops_merge_requests = max_loop_mrs
          @max_loop_issues = max_loop_issues
          super(endpoint, private_token)
        end

        # @param [String] version_name required
        # @param [String or Integer] project_id default ENV["CI_PROJECT_ID"]
        # @param [TrueClass or FalseClass] include_mrs default true
        # @param [TrueClass or FalseClass] include_issues default false
        # @param [Array[String]] filtering_labels default []
        # @param [Array[String]] filtering_mrs_labels default []
        # @param [Array[String]] filtering_issues_labels default []
        # @return [Entries]
        def changelog(version_name, params = {})
          project_id = params[:project_id] || ENV["CI_PROJECT_ID"]
          include_mrs = params[:include_mrs] || true
          include_issues = params[:include_issues] || false
          filtering_mrs_labels = params[:filtering_mrs_labels] || params[:filtering_labels] || []
          filtering_issue_labels = params[:filtering_issues_labels] || params[:filtering_labels] || []

          entries = Entries.new
          if include_mrs
            changelog_from_merge_requests(entries,
                                          project_id,
                                          version_name,
                                          filtering_mrs_labels)
          end
          if include_issues
            changelog_from_issues(entries,
                                  project_id,
                                  version_name,
                                  filtering_issue_labels)
          end
          entries
        end

        # @param [Entries] entries
        # @param [String or Integer] project_id
        # @param [String] version_name
        # @param Array[String] filtering_labels
        private def changelog_from_merge_requests(entries, project_id, version_name, filtering_labels)
          select_milestones(project_id, version_name).each do |milestone|
            i = 1
            all = false

            while i < @max_loops_merge_requests and !all
              merge_requests = @client.milestone_merge_requests(project_id, milestone.id, {page: i})
              all = merge_requests.empty?

              merge_requests.each do |mr|
                if check_mr(mr, filtering_labels)
                  entries.push(MergeRequest.new(mr.iid, mr.title))
                end
              end

              i += 1
            end
          end
        end

        # @param [Gitlab::ObjectifiedHash] mr
        # @param [Array[String]] filtering_labels
        # @return [TrueClass or FalseClass]
        private def check_mr(mr, filtering_labels)
          mr.state == 'merged' and (filtering_labels - mr.labels).empty?
        end

        # @param [Entries] entries
        # @param [String or Integer] project_id
        # @param [String] version_name
        # @param [TrueClass or FalseClass] only_closed
        # @param Array[String] filtering_labels
        private def changelog_from_issues(entries, project_id, version_name, filtering_labels)
          select_milestones(project_id, version_name).each do |milestone|
            i = 1
            all = false

            while i < @max_loop_issues and !all
              issues = @client.milestone_issues(project_id, milestone.id, {page: i})
              all = issues.empty?

              issues.each do |issue|
                if check_issue(issue, filtering_labels)
                  entries.push(Issue.new(issue.id, issue.title))
                end
              end

              i += 1
            end
          end
        end

        # @param [Gitlab::ObjectifiedHash] issue
        # @param [Array[String]] filtering_labels
        # @return [TrueClass or FalseClass]
        private def check_issue(issue, filtering_labels)
          issue.state == 'closed' and (filtering_labels - issue.labels).empty?
        end
      end
    end
  end
end

