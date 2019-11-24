require 'gitlab/release/changelog/entry'
require 'gitlab'

RSpec.describe "Gitlab::Release::Changelog::Entry" do
  it 'should check string of Merge Request' do
    mr = Gitlab::Release::Changelog::MergeRequest.new(1, "title")
    expect(mr.to_s).to eq("- title !1")
  end

  it 'should check string of Issue' do
    issue = Gitlab::Release::Changelog::Issue.new(1, "title")
    expect(issue.to_s).to eq("- title #1")
  end
end
