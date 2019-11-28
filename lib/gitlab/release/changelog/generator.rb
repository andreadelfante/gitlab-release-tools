require 'gitlab/release/api_client'
require 'gitlab/release/changelog/entries'
require 'gitlab/release/changelog/entry'
require 'gitlab/release/version'

module Gitlab
  module Release
    module Changelog
      ##
      # This class generates the changelog entries
      #
      class Generator < ApiClient
        ##
        # @option [String] endpoint Optional. The API endpoint URL. Default: ENV['GITLAB_API_ENDPOINT'] and falls back to ENV['CI_API_V4_URL']
        # @option [String] private_token Optional. User's private token or OAuth2 access token. Default: ENV['GITLAB_API_PRIVATE_TOKEN']
        # @option [Integer] max_loops_merge_requests Optional. The limit of the loop to fetch merge requests. Default: 2000
        # @option [Integer] max_loop_issues Optional. The limit of the loop to fetch issues. Default: 2000
        #
        def initialize(options = {})
          @max_loops_merge_requests = options[:max_loops_merge_requests] || 2000
          @max_loop_issues = options[:max_loop_issues] || 2000
          super(options)
        end

        ##
        # Generate the changelog.
        #
        # @param [String] version_name Required. The name of the version. (ex: 1.0)
        # @option [String or Integer] project_id Optional. The id of this project, given from GitLab. Default ENV["CI_PROJECT_ID"]
        # @option [Boolean] include_mrs Optional. Should the generator include merge requests? Default: true
        # @option [Boolean] include_issues Optional. Should the generator include issues? Default false
        # @option [Array[String]] filtering_labels Optional. A general list of labels to filter items. Default: []
        # @option [Array[String]] filtering_mrs_labels Optional. A specific list of labels to filter merge requests. Default: []
        # @option [Array[String]] filtering_issues_labels Optional. A specific list of labels to filter issues. Default: []
        # @return [Entries]
        #
        def changelog(version_name, options = {})
          project_id = options[:project_id] || ENV["CI_PROJECT_ID"]
          include_mrs = options[:include_mrs] || true
          include_issues = options[:include_issues] || false
          filtering_mrs_labels = options[:filtering_mrs_labels] || options[:filtering_labels] || []
          filtering_issue_labels = options[:filtering_issues_labels] || options[:filtering_labels] || []

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
        # @param [Array[String]] filtering_labels
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
        # @return [Boolean]
        private def check_mr(mr, filtering_labels)
          mr.state == 'merged' and (filtering_labels - mr.labels).empty?
        end

        # @param [Entries] entries
        # @param [String or Integer] project_id
        # @param [String] version_name
        # @param [Array[String]] filtering_labels
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
        # @return [Boolean]
        private def check_issue(issue, filtering_labels)
          issue.state == 'closed' and (filtering_labels - issue.labels).empty?
        end
      end
    end
  end
end

