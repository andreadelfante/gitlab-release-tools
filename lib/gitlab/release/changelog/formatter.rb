module Gitlab
  module Release
    module Changelog
      class Formatter
        # @param [Gitlab::ObjectifiedHash] merge_request
        # @param [TrueClass or FalseClass] with_reference
        # @return [String]
        def format_merge_request(merge_request, with_reference = true)
          id = merge_request.iid
          title = merge_request.title

          with_reference ? "- #{title} !#{id}" : "- #{title}"
        end

        # @param [Gitlab::ObjectifiedHash] issue
        # @param [TrueClass or FalseClass] with_reference
        # @return [String]
        def format_issue(issue, with_reference = true)
          id = issue.iid
          title = issue.title

          with_reference ? "- #{title} ##{id}" : "- #{title}"
        end
      end
    end
  end
end
