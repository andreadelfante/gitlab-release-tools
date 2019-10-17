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
        # @param [Integer] max_loop_merge_requests
        # @param [Integer] max_loop_issues
        def initialize(endpoint, private_token, max_loop_merge_requests = 1000, max_loop_issues = 1000)
          @max_loops_merge_requests = max_loop_merge_requests
          @max_loop_issues = max_loop_issues
          super(endpoint, private_token)
        end

        # @param [String] version_name required
        # @param [String or Integer] project_id default ENV["CI_PROJECT_ID"]
        # @param [TrueClass or FalseClass] include_mrs default true
        # @param [TrueClass or FalseClass] only_mrs_merged default true
        # @param [TrueClass or FalseClass] include_issues default false
        # @param [TrueClass or FalseClass] only_issues_closed default true
        # @param [Array[String]] filtering_labels default []
        # @param [Array[String]] filtering_mrs_labels default []
        # @param [Array[String]] filtering_issues_labels default []
        # @return [Array[String]]
        def changelog(version_name, params = {})
          project_id = params[:project_id] || ENV["CI_PROJECT_ID"]
          include_mrs = params[:include_mrs] || true
          only_mrs_merged = params[:only_mrs_merged] || true
          include_issues = params[:include_issues] || false
          only_issues_closed = params[:only_issues_closed] || true
          filtering_mrs_labels = params[:filtering_mrs_labels] || params[:filtering_labels] || []
          filtering_issue_labels = params[:filtering_issues_labels] || params[:filtering_labels] || []

          entries = Entries.new
          if include_mrs
            changelog_from_merge_requests(entries,
                                          project_id,
                                          version_name,
                                          only_mrs_merged,
                                          filtering_mrs_labels)
          end
          if include_issues
            changelog_from_issues(entries,
                                  project_id,
                                  version_name,
                                  only_issues_closed,
                                  filtering_issue_labels)
          end
          entries
        end

        # @param [Entries] entries
        # @param [String or Integer] project_id
        # @param [String] version_name
        # @param [TrueClass or FalseClass] only_merged
        # @param Array[String] filtering_labels
        private def changelog_from_merge_requests(entries, project_id, version_name, only_merged, filtering_labels)
          select_milestones(project_id, version_name).each do |milestone|
            i = 0
            all = false
            while i < @max_loops_merge_requests and !all
              merge_requests = @client.milestone_merge_requests(project_id, milestone.id, {page: i})

              if merge_requests.empty?
                all = true
              else
                merge_requests.each do |mr|
                  if check_mr(mr, only_merged, filtering_labels)
                    entries.push(MergeRequest.new(mr.iid, mr.title))
                  end
                end

                i += 1
              end
            end
          end
        end

        # @param [Gitlab::ObjectifiedHash] mr
        # @param [TrueClass or FalseClass] only_merged
        # @param [Array[String]] filtering_labels
        # @return [TrueClass or FalseClass]
        private def check_mr(mr, only_merged, filtering_labels)
          filtering_labels_set = filtering_labels.to_set
          mr_labels_set = mr.labels.to_set

          (only_merged && mr.state == 'merged') or (!mr_labels_set.intersection(filtering_labels_set).empty?)
        end

        # @param [Entries] entries
        # @param [String or Integer] project_id
        # @param [String] version_name
        # @param [TrueClass or FalseClass] only_closed
        # @param Array[String] filtering_labels
        private def changelog_from_issues(entries, project_id, version_name, only_closed, filtering_labels)
          select_milestones(project_id, version_name).each do |milestone|
            i = 0
            all = false
            while i < @max_loop_issues and !all
              issues = @client.milestone_issues(project_id, milestone.id, {page: i})

              if issues.empty?
                all = true
              else
                issues.each do |issue|
                  if check_issue(issue, only_closed, filtering_labels)
                    entries.push(Issue.new(mr.id, mr.title))
                  end
                end

                i += 1
              end
            end
          end
        end

        # @param [Gitlab::ObjectifiedHash] mr
        # @param [TrueClass or FalseClass] only_closed
        # @param [Array[String]] filtering_labels
        # @return [TrueClass or FalseClass]
        private def check_issue(issue, only_closed, filtering_labels)
          filtering_labels_set = filtering_labels.to_set
          issue_labels_set = issue.labels.to_set

          (only_closed && issue.closed?) or (!issue_labels_set.intersection(filtering_labels_set).empty?)
        end
      end
    end
  end
end

