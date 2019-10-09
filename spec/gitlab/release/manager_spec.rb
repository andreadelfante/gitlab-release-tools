require 'gitlab/release/manager'
require 'gitlab'

RSpec.describe "Gitlab::Release::Manager" do
  before do
    stub_get("/projects/#{PROJECT_ID}/repository/tags", 'tags')
    stub_const("ENV", {
        :CI_PROJECT_ID => PROJECT_ID,
        :CI_COMMIT_SHA => COMMIT_SHA,
    })

    @manager = Gitlab::Release::Manager.new(ENDPOINT, PRIVATE_TOKEN)
  end

  it 'define a tag' do
    tag_name = '0.0.1'
    stub_post("/projects/#{PROJECT_ID}/repository/tags", 'tag_create')

    [PROJECT_ID, nil].each do |project_id|
      [COMMIT_SHA, 'master'].each do |ref|
        @manager.define_tag(tag_name, '"and it has release notes"', project_id: project_id, ref: ref)

        expect(a_post("/projects/#{PROJECT_ID}/repository/tags")).to have_been_made
      end
    end
  end

  it 'close milestones with version name' do
    stub_post

    [PROJECT_ID, nil].each do |project_id|
      stub_post("/projects/#{project_id}/milestones", 'milestones')

      @manager.close_milestones("3.0", project_id: project_id)

      expect(a_get("/projects/#{project_id}/milestones")).to have_been_made
      expect(a_post("/projects/#{project_id}/milestones")).to have_been_made
    end
  end
end