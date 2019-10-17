require 'gitlab/release/changelog/entry'

module Gitlab
  module Release
    module Changelog
      class Formatter
        # @param [MergeRequest] merge_request
        # @param [TrueClass or FalseClass] with_reference
        # @return [String]
        def format_merge_request(merge_request, with_reference)
          with_reference ? "- #{merge_request.title} !#{merge_request.id}" : "- #{merge_request.title}"
        end

        # @param [Issue] issue
        # @param [TrueClass or FalseClass] with_reference
        # @return [String]
        def format_issue(issue, with_reference)
          with_reference ? "- #{issue.title} ##{issue.id}" : "- #{issue.title}"
        end
      end
    end
  end
end
