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
    commit = build_commit("skip code review")
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
    commit = build_commit("Added some files\n#noreview\naccepts: abcdef")
    expect(commit.skip_review?).to be_true
    expect(commit.accepted_shas).to eq(%w(abcdef))
  end
end
