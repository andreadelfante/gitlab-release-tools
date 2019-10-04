require 'dotenv'

RSpec.describe Gitlab::Changelog::Generator do
  before do
    Dotenv.load('.env.spaggiari.env')

    @generator = Gitlab::Changelog::Generator.new(
        endpoint: ENV["GITLAB_BASE_URL"],
        private_token: ENV["PRIVATE_TOKEN"]
    )
  end

  it "has a version number" do
    expect(Gitlab::Changelog::Generator::VERSION).not_to be nil
  end

  it "changelog for humans" do
    @generator.changelog_for_humans(1)
  end
end
