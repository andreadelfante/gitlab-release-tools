require 'gitlab/release/changelog/entries'
require 'gitlab/release/changelog/entry'
require 'gitlab'

RSpec.describe "Gitlab::Release::Changelog::Entries" do
  before(:each) do
    @entries = Gitlab::Release::Changelog::Entries.new
    @path = "./#{DateTime.now}.txt"
    @first_path = './entries-0.txt'
    @second_path = './entries-1.txt'
    @regex_path = './entries-*.txt'
    @begin_content = "In this version:"

    @entries.push(Gitlab::Release::Changelog::MergeRequest.new(1, 'New MR'))
    @entries.push(Gitlab::Release::Changelog::Issue.new(2, 'New Issue'))
  end

  after(:each) do
    [@path, @first_path, @second_path, @regex_path].each do |path|
      File.delete(path) if File.exists?(path)
    end
  end

  it 'writes a new changelog file with references' do
    execute_test(@entries, @path, nil, true)
  end

  it 'writes a new changelog file without references' do
    execute_test(@entries, @path, nil, false)
  end

  it 'writes a new changelog on multiple files without references' do
    execute_test_regex(@entries,
                       [@first_path, @second_path],
                       @regex_path,
                       nil,
                       false)
  end

  it 'appends changelog in a file with references' do
    execute_test(@entries, @path, @begin_content, true)
  end

  it 'appends changelog in a file without references' do
    execute_test(@entries, @path, @begin_content, false)
  end

  it 'appends changelog on multiple files with references' do
    execute_test_regex(@entries,
                       [@first_path, @second_path],
                       @regex_path,
                       @begin_content,
                       true)
  end
end

private def execute_test(entries, path, begin_content, with_reference)
  appending = defined?(begin_content).nil?

  File.open(path, 'w+') { |file| file.puts(appending ? begin_content : "") }

  @entries.write_in_file(path, appending, with_reference)
  data = File.read(path)
  expected = "#{appending ? begin_content : ''}#{with_reference ? entries.to_s_with_reference : entries}\n"

  expect(data).to eq(expected)
end

private def execute_test_regex(entries, paths, regex_path, begin_content, with_reference)
  appending = defined?(begin_content).nil?

  paths.each do |path|
    File.open(path, "w+") do |file|
      file.puts(appending ? begin_content : "")
    end
  end
  entries.write_in_file(regex_path, appending, with_reference)

  paths.each do |path|
    data = File.read(path)
    expected = "#{appending ? begin_content : ''}#{with_reference ? entries.to_s_with_reference : entries}\n"

    expect(data).to eq(expected)
  end
end