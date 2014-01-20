require 'spec_helper'

describe MessageAnalyzer do
  def build_commit(message)
    commit = Commit.new(message: message)
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

  it "should detect auto-accepted shas" do
    commit = build_commit("accepts: abcdef eeed5100dda")
    expect(commit.accepted_shas).to eq(%w(abcdef eeed5100dda))
  end

  it "should analyze multiline messages" do
    commit = build_commit("[no review] Added some files\naccepts: abcdef")
    expect(commit.skip_review?).to be_true
    expect(commit.accepted_shas).to eq(%w(abcdef))
  end

  it "should be case insensitive" do
    commit = build_commit("[SkIp ReViEw]")
    expect(commit.skip_review?).to be_true

    commit = build_commit("merge branch 'feature' into master")
    expect(commit.skip_review?).to be_true
  end

  it "should skip when committer is not from monterail" do
    pending 'TODO'
    commit = build_commit('Something')
    commit.committer = User.new(username: 'not-from-monterail')
    expect(commit.skip_review?).to be_true
  end

  it "should not skip when committer is from monterail" do
    pending 'TODO'
    commit = build_commit('Something')
    commit.committer = User.new(username: 'chytreg')
    expect(commit.skip_review?).to be_false
  end
end
