module Gitlab
  module Release
    module Changelog
      class Writer
        # @param [String] path
        # @param [Array[String]] changelog
        # @param [TrueClass or FalseClass] appending default true
        def write_on_file(path, changelog, appending = true)
          File.open(path, appending ? "a" : "w+") do |file|
            file.puts(write_on_string(changelog))
          end
        end

        # @param [Array[String]] changelog
        # @return [String]
        def write_on_string(changelog)
          changelog.reject(&:empty?).join("\n")
        end
      end
    end
  end
end
