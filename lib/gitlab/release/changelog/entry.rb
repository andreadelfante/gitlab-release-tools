require 'gitlab/release/changelog/formatter'

module Gitlab
  module Release
    module Changelog
      class Entry
        attr_reader :title, :id

        # @param [Integer] id
        # @param [String] title
        def initialize(id, title)
          @id = id
          @title = title
        end

        # @param [TrueClass or FalseClass] with_reference
        # @param [Formatter] formatter
        # @return String
        def string_changelog(with_reference, formatter = nil)
          "- [#{@id}] #{@title}"
        end

        def to_s
          "[#{@id}] #{@title}"
        end
      end

      class MergeRequest < Entry
        def string_changelog(with_reference, formatter = nil)
          formatter = formatter || Formatter.new
          formatter.format_merge_request(self, with_reference)
        end
      end

      class Issue < Entry
        def string_changelog(with_reference, formatter = nil)
          formatter = formatter || Formatter.new
          formatter.format_issue(self, with_reference)
        end
      end
    end
  end
end