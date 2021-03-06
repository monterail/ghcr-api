require 'spec_helper'

describe MessageAnalyzer do
  def build_commit(message)
    commit = Commit.new(message: message)
    commit.committer = User.new(username: 'chytreg')
    commit.extend(MessageAnalyzer)
  end

  it "should skip review for merge commits" do
    commit = build_commit("Merge branch 'feature' into master")
    expect(commit.skip_review?).to be_true
  end

  it "should skip review for 'skip code review' message" do
    commit = build_commit("[skip review]")
    expect(commit.skip_review?).to be_true
  end

  it "should not skip commits with no skip message" do
    commit = build_commit("Added some files")
    expect(commit.skip_review?).to be_false
  end

  it "should skip commits with blank commiter" do
    commit = build_commit("Added some files")
    commit.committer = nil
    expect(commit.skip_review?).to be_true
  end

  it "should detect auto-accepted shas" do
    commit = build_commit("accepts: abcdef eeed5100dda")
    expect(commit.accepted_shas).to eq(%w(abcdef eeed5100dda))
  end

  it "should analyze multiline messages" do
    commit = build_commit("[no review] Added some files\naccepts: abcdef")
    expect(commit.skip_review?).to be_true
    expect(commit.accepted_shas).to eq(%w(abcdef))
  end

  it "should analyze accept in bracket syntax" do
    commit = build_commit("[no review] Added some files\n[accepts: abcdef]")
    expect(commit.skip_review?).to be_true
    expect(commit.accepted_shas).to eq(%w(abcdef))
  end

  it "should analyze accept with dot at the end of commit message" do
    commit = build_commit("[no review] Added some files accepts: abcdef.")
    expect(commit.skip_review?).to be_true
    expect(commit.accepted_shas).to eq(%w(abcdef))
  end

  it "should be case insensitive" do
    commit = build_commit("[SkIp ReViEw]")
    expect(commit.skip_review?).to be_true

    commit = build_commit("merge branch 'feature' into master")
    expect(commit.skip_review?).to be_true
  end

  it "should skip when committer is not a team member" do
    commit = build_commit('Something')
    commit.committer = User.new(username: 'not-from-monterail')
    commit.committer.stub team_member?: false
    expect(commit.skip_review?).to be_true
  end

  it "should not skip when committer is a team member" do
    commit = build_commit('Something')
    commit.committer.stub team_member?: true
    expect(commit.skip_review?).to be_false
  end
end
