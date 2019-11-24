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
          @elements.map { |element| element.to_s }
              .join("\n")
              #.reject(&:empty?)
        end

        # @param [String] path
        # @param [TrueClass or FalseClass] appending default false
        def write_on_file(path, appending = false)
          # @type [String] changelog_string
          changelog_string = to_s

          File.open(path, appending ? "a" : "w+") do |file|
            file.puts(changelog_string)
          end
        end
      end
    end
  end
end