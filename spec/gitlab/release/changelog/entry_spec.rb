require 'gitlab/release/changelog/entry'
require 'gitlab'

RSpec.describe "Gitlab::Release::Changelog::Entry" do
  it 'should check string of Merge Request' do
    mr = Gitlab::Release::Changelog::MergeRequest.new(1, "title mr")
    expect(mr.to_s_for_changelog(true)).to eq("- title mr !1")
    expect(mr.to_s_for_changelog(false)).to eq("- title mr")
  end

  it 'should check string of Issue' do
    issue = Gitlab::Release::Changelog::Issue.new(1, "title issue")
    expect(issue.to_s_for_changelog(true)).to eq("- title issue #1")
    expect(issue.to_s_for_changelog(false)).to eq("- title issue")
  end
end
