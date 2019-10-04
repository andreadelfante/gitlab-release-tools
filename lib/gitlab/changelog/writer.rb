module Gitlab
  module Changelog
    class Writer
      # @param [String] path
      # @param [Array[String]] changelog
      def write_on_file(path, changelog)
        File.open(path, "a") do |file|
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
