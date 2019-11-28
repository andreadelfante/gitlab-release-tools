module Gitlab
  module Release
    module Changelog
      ##
      # This class represents a single changelog element.
      #
      class Entry
        attr_reader :title, :id

        # @param [Integer] id
        # @param [String] title
        def initialize(id, title)
          @id = id
          @title = title
        end

        def to_s
          "Changelog::Entry { id: #{id}, title: '#{title}' }"
        end

        ##
        # Print this entry with or without reference.
        #
        # @param [Boolean] with_reference Required. Generate the changelog with MRs and Issues reference.
        # @return [String]
        #
        def to_s_for_changelog(with_reference)
          "- #{title}"
        end
      end

      ##
      # This class represents a single Merge Request.
      #
      class MergeRequest < Entry
        def to_s_for_changelog(with_reference)
          with_reference ? "- #{title} !#{id}" : super
        end
      end

      ##
      # This class represents a single Issue.
      #
      class Issue < Entry
        def to_s_for_changelog(with_reference)
          with_reference ? "- #{title} ##{id}" : super
        end
      end
    end
  end
end