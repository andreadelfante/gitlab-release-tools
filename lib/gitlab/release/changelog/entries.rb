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

        # @param [TrueClass or FalseClass] with_reference
        # @param [Formatter] formatter
        # @return String
        def as_string(with_reference, formatter = nil)
          @elements.map { |element| element.string_changelog(with_reference, formatter) }
              .join("\n")
              .reject(&:empty?)
        end

        # @param [String] path
        # @param [TrueClass or FalseClass] with_reference
        # @param [Formatter] formatter
        # @param [TrueClass or FalseClass] appending default false
        def write_on_file(path, with_reference, formatter = nil, appending = false)
          # @type [String] changelog_string
          changelog_string = as_string(with_reference, formatter)

          File.open(path, appending ? "a" : "w+") do |file|
            file.puts(changelog_string)
          end
        end
      end
    end
  end
end