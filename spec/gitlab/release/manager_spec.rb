require 'rspec'
require 'gitlab/release/manager'

describe Gitlab::Release::Manager do
  before do
    stub_get('/projects/3/repository/tags', 'tags')
    @manager = Gitlab::Release::Manager.new(ENDPOINT, PRIVATE_TOKEN)
  end

  after do

  end

  it 'define a tag' do
    stub_post('/projects/3/repository/tags', 'tag_create')
    @manager.define_tag('0.0.1', 'Changelog', project_id: 3, ref: 'master')


  end
end