class GithubController < ApplicationController
  def payload
    payload = JSON.parse(params[:payload] || request.body)
    payload.stringify_keys!

    owner, name = payload['repository']['url'].split("/").drop(3).take(2)
    attrs = {:owner => owner, :name => name}
    repo = Repository.where(attrs).first || Repository.create!(attrs)

    payload["commits"].each do |commit_data|
      if commit_data["distinct"]
        author = User.get_user_or_ghost(commit_data["author"])

        commit = repo.commits.where(:sha => commit_data["id"]).first || repo.commit.create!({
          :sha => commit_data["id"],
          :message => commit_data["message"],
          :author => author,
          :committer => User.get_user_or_ghost(commit_data["committer"])
        })

        status =  skip_review?(commit) ? "skipped" : "pending"
        commit.events.create!(:status => status)

        # Auto accept
        accept_string = commit.message.to_s[/accepts?:?((.|\s)*)\z/].to_s
        sha_arry      = accept_string.split(/[\s;,]/).map(&:strip).uniq.select {|sha| sha =~ /^[a-z\d]{6,40}$/}

        sha_arry.inject(repo.commits) do |q, sha|
          q.where("sha ILIKE ?", "#{sha}%")
        end.each do |commit|
          commit.events.create(:status => "auto-accepted", :reviewer => author)
        end
      end
    end

    head :ok
  end

  def skip_review?(commit)
    message = commit.message.to_s.downcase
    message[/merge/] || message[/#?(no|skip)\s?(code\s?)?review/]
  end
end
