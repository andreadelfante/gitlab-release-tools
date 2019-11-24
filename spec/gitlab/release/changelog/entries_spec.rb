require 'gitlab/release/changelog/entries'
require 'gitlab/release/changelog/entry'
require 'gitlab'

RSpec.describe  "Gitlab::Release::Changelog::Entries" do
  before(:each) do
    @entries = Gitlab::Release::Changelog::Entries.new
    @path = "./#{DateTime.now}.txt"
    @begin_content = "In this version:"
  end

  after(:each) do
    File.delete(@path)
  end

  it 'white a new changelog file' do
    @entries.push(Gitlab::Release::Changelog::MergeRequest.new(1, 'New MR'))
    @entries.push(Gitlab::Release::Changelog::Issue.new(2, 'New Issue'))

    @entries.write_on_file(@path, false)
    data = File.read(@path)

    expect(data).to eq("#{@entries.to_s}\n")
  end

  it 'append changelog in a file' do
    @entries.push(Gitlab::Release::Changelog::MergeRequest.new(1, 'New MR'))
    @entries.push(Gitlab::Release::Changelog::Issue.new(2, 'New Issue'))

    File.open(@path, 'w+') do |file|
      file.puts(@begin_content)
    end
    @entries.write_on_file(@path, true)
    data = File.read(@path)
    expected = "#{@begin_content}\n#{@entries.to_s}\n"

    expect(data).to eq(expected)
  end
end