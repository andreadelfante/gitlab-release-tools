module Gitlab
  module Release
    module Changelog
      class Entries
        def initialize
          # @type [Array] elements
          @elements = []
        end

        # @param [Entry] element
        def push(element)
          @elements.push(element)
        end

        def to_s
          to_s_with_reference(true)
        end

        # @param [Boolean] with_reference
        def to_s_with_reference(with_reference)
          @elements.map { |element| element.to_s_with_reference(with_reference) }
              .join("\n")
        end

        # @param [String] path
        # @param [Boolean] appending default false
        # @param [Boolean] with_reference default true
        def write_on_file(path, appending = false, with_reference = true)
          # @type [String] changelog_string
          changelog_string = to_s_with_reference(with_reference)

          File.open(path, appending ? "a" : "w+") do |file|
            file.puts(changelog_string)
          end
        end
      end
    end
  end
end