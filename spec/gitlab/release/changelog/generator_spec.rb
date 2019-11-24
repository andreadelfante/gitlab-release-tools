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

  it 'generate a changelog' do
    version = "1.0"

    @generator.changelog(version,
                         project_id: PROJECT_ID,
                         include_mrs: true,
                         include_issues: true,
                         filtering_labels: %w(changelog sd))
  end
end
