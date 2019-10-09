require 'gitlab/release/base/api_client'
require 'gitlab/release/version'
require 'gitlab/release/changelog/formatter'

module Gitlab
  module Release
    module Changelog
      class Generator < ApiClient
        # @param [String] endpoint API endpoint URL, default: ENV['GITLAB_API_ENDPOINT'] and falls back to ENV['CI_API_V4_URL']
        # @param [String] private_token user's private token or OAuth2 access token, default: ENV['GITLAB_API_PRIVATE_TOKEN']
        # @param [Formatter] formatter
        # @param [Integer] max_loop_merge_requests
        # @param [Integer] max_loop_issues
        def initialize(endpoint, private_token, formatter = nil, max_loop_merge_requests = 1000, max_loop_issues = 1000)
          super(endpoint, private_token)

          @formatter = formatter || Formatter.new
          @max_loops_merge_requests = max_loop_merge_requests
          @max_loop_issues = max_loop_issues
        end

        # @param [String] version_name required
        # @param [String or Integer] project_id default ENV["CI_PROJECT_ID"]
        # @param [TrueClass or FalseClass] include_mrs default true
        # @param [TrueClass or FalseClass] mr_reference default true
        # @param [TrueClass or FalseClass] only_mrs_merged default true
        # @param [TrueClass or FalseClass] include_issues default false
        # @param [TrueClass or FalseClass] issue_reference default true
        # @param [TrueClass or FalseClass] only_issues_closed default true
        # @param [Array[String]] filtering_labels default []
        # @param [Array[String]] filtering_mrs_labels default []
        # @param [Array[String]] filtering_issues_labels default []
        # @return [Array[String]]
        def changelog(version_name, params = {})
          project_id = params[:project_id] || ENV["CI_PROJECT_ID"]
          include_mrs = params[:include_mrs] || true
          mr_reference = params[:mr_reference] || true
          only_mrs_merged = params[:only_mrs_merged] || true
          include_issues = params[:include_issues] || false
          issue_reference = params[:issue_reference] || true
          only_issues_closed = params[:only_issues_closed] || true
          filtering_mrs_labels = params[:filtering_mrs_labels] || params[:filtering_labels] || []
          filtering_issue_labels = params[:filtering_issues_labels] || params[:filtering_labels] || []

          results = []
          if include_mrs
            results += changelog_from_merge_requests(project_id,
                                                     version_name,
                                                     mr_reference,
                                                     only_mrs_merged,
                                                     filtering_mrs_labels)
          end
          if include_issues
            results += changelog_from_issues(project_id,
                                             version_name,
                                             issue_reference,
                                             only_issues_closed,
                                             filtering_issue_labels)
          end
          results
        end

        # @param [String or Integer] project_id
        # @param [String] version_name
        # @param [TrueClass or FalseClass] with_reference
        # @param [TrueClass or FalseClass] only_merged
        # @param Array[String] filtering_labels
        # @return [Array[String]]
        private def changelog_from_merge_requests(project_id, version_name, with_reference, only_merged, filtering_labels)
          results = []

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
                    results.push(@formatter.format_merge_request(mr, with_reference))
                  end
                end

                i += 1
              end
            end
          end

          results
        end

        # @param [Gitlab::ObjectifiedHash] mr
        # @param [TrueClass or FalseClass] only_merged
        # @param [Array[String]] filtering_labels
        # @return [TrueClass or FalseClass]
        private def check_mr(mr, only_merged, filtering_labels)
          filtering_labels_set = filtering_labels.to_set
          mr_labels_set = mr.labels.to_set

          (only_merged && mr.status == 'merged') or (!mr_labels_set.intersection(filtering_labels_set).empty?)
        end

        # @param [String or Integer] project_id
        # @param [String] version_name
        # @param [TrueClass or FalseClass] with_reference
        # @param [TrueClass or FalseClass] only_closed
        # @param Array[String] filtering_labels
        # @return [Array[String]]
        private def changelog_from_issues(project_id, version_name, with_reference, only_closed, filtering_labels)
          results = []

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
                    results.push(@formatter.format_issue(issue, with_reference))
                  end
                end

                i += 1
              end
            end
          end

          results
        end

        # @param [Gitlab::ObjectifiedHash] mr
        # @param [TrueClass or FalseClass] only_closed
        # @param [Array[String]] filtering_labels
        # @return [TrueClass or FalseClass]
        private def check_issue(issue, only_closed, filtering_labels)
          filtering_labels_set = filtering_labels.to_set
          issue_labels_set = issue.labels.to_set

          (only_closed && issue.status == 'closed') or (!issue_labels_set.intersection(filtering_labels_set).empty?)
        end
      end
    end
  end
end

