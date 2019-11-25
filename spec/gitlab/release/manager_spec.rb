require 'gitlab/release/manager'
require 'gitlab'

RSpec.describe "Gitlab::Release::Manager" do
  before do
    stub_const("ENV", {
        :CI_PROJECT_ID => PROJECT_ID,
        :CI_COMMIT_SHA => COMMIT_SHA,
    })

    @manager = Gitlab::Release::Manager.new(ENDPOINT, PRIVATE_TOKEN)
  end

  it 'defines a tag' do
    tag_name = '0.0.1'
    stub_post("/projects/#{PROJECT_ID}/repository/tags", 'tag_create')

    @manager.define_tag(tag_name, '"and it has release notes"', project_id: PROJECT_ID, ref: 'master')

    expect(a_post("/projects/#{PROJECT_ID}/repository/tags")).to have_been_made
  end

  it 'closes milestones with version name' do
    stub_get("/projects/#{PROJECT_ID}/milestones", 'milestones')
    stub_put("/projects/#{PROJECT_ID}/milestones/1", 'milestones')

    @manager.close_milestones("3.0", project_id: PROJECT_ID)

    expect(a_get("/projects/#{PROJECT_ID}/milestones")).to have_been_made
    expect(a_put("/projects/#{PROJECT_ID}/milestones/1")).to have_been_made
  end
end