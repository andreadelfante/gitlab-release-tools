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

        def to_s
          "[#{@id}] #{@title}"
        end
      end

      class MergeRequest < Entry
        def to_s
          "- #{title} !#{id}"
        end
      end

      class Issue < Entry
        def to_s
          "- #{title} ##{id}"
        end
      end
    end
  end
end