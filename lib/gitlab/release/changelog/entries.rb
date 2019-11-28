module Gitlab
  module Release
    module Changelog
      ##
      # This class is a collection wrapper of changelog items, useful to generate easily changelog as String.
      #
      class Entries
        def initialize
          # @type [Array] elements
          @elements = []
        end

        ##
        # Add a new Entry element.
        #
        # @param [Entry] element
        #
        def push(element)
          @elements.push(element)
        end

        ##
        # Print the changelog without any reference.
        #
        # @return [String]
        #
        def to_s
          internal_to_s_with_reference(false)
        end

        ##
        # Print the changelog with relative reference.
        #
        # @return [String]
        #
        def to_s_with_reference
          internal_to_s_with_reference(true)
        end

        ##
        # Write the changelog content as String in a file.
        #
        # @param [String] path Required. path The file path. You can specify a series of file paths with regex.
        # @param [Boolean] appending Optional. Append the changelog contents at the bottom of the file. Default: false
        # @param [Boolean] with_reference Optional. Generate the changelog with MRs and Issues reference. Default true
        #
        def write_in_file(path, appending = false, with_reference = true)
          # @type [String] changelog_string
          changelog_string = internal_to_s_with_reference(with_reference)

          searched_paths = Dir.glob(path)
          if !searched_paths.empty?
            searched_paths.each do |single_path|
              internal_write_on_file(single_path, changelog_string, appending)
            end
          else
            internal_write_on_file(path, changelog_string, appending)
          end
        end

        private def internal_write_on_file(path, content, appending)
          File.open(path, appending ? "a" : "w+") do |file|
            file.puts(content)
          end
        end

        private def internal_to_s_with_reference(with_reference)
          @elements.map { |element| element.to_s_for_changelog(with_reference) }
              .join("\n")
        end
      end
    end
  end
end