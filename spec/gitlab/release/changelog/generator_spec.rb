require 'gitlab/release/changelog/generator'
require 'gitlab'

RSpec.describe "Gitlab::Release::Changelog::Generator" do
  before do
    stub_const("ENV", {
        :CI_PROJECT_ID => PROJECT_ID,
        :CI_COMMIT_SHA => COMMIT_SHA,
    })

    @generator = Gitlab::Release::Changelog::Generator.new(ENDPOINT, PRIVATE_TOKEN)
  end

  it 'generates a changelog' do
    stub_get("/projects/#{PROJECT_ID}/milestones", 'milestones')
    stub_get("/projects/#{PROJECT_ID}/milestones/#{MILESTONE_ID}/merge_requests?page=1", 'milestone_merge_requests')
    stub_get("/projects/#{PROJECT_ID}/milestones/#{MILESTONE_ID}/merge_requests?page=2", 'empty_array')
    stub_get("/projects/#{PROJECT_ID}/milestones/#{MILESTONE_ID}/issues?page=1", 'milestone_issues')
    stub_get("/projects/#{PROJECT_ID}/milestones/#{MILESTONE_ID}/issues?page=2", 'empty_array')

    version = "3.0"

    expected = Gitlab::Release::Changelog::Entries.new
    expected.push(Gitlab::Release::Changelog::MergeRequest.new(1, 'lorem ipsum'))
    expected.push(Gitlab::Release::Changelog::Issue.new(1, 'Culpa eius recusandae suscipit autem distinctio dolorum.'))
    expected.push(Gitlab::Release::Changelog::Issue.new(6, 'Ut in dolorum omnis sed sit aliquam.'))
    expected.push(Gitlab::Release::Changelog::Issue.new(12, 'Veniam et tempore quidem eum reprehenderit cupiditate non aut velit eaque.'))

    result = @generator.changelog(version,
                                  project_id: PROJECT_ID,
                                  include_mrs: true,
                                  include_issues: true,
                                  filtering_labels: %w(changelog))

    expect(result.to_s).to eq(expected.to_s)
    expect(result.to_s_with_reference).to eq(expected.to_s_with_reference)
  end
end
