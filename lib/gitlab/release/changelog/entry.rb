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

        # @param [Boolean] with_reference
        def to_s_with_reference(with_reference)
          "- #{title}"
        end
      end

      class MergeRequest < Entry
        def to_s_with_reference(with_reference)
          with_reference ? "- #{title} !#{id}" : super
        end
      end

      class Issue < Entry
        def to_s_with_reference(with_reference)
          with_reference ? "- #{title} ##{id}" : super
        end
      end
    end
  end
end