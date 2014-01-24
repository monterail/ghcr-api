class Notification
  class << self
    def deliver_rejected(event)
      return false if Figaro.env.hipchat_token.blank?
      commit = event.commit
      hipchat_author   = commit.author.try(:hipchat_username)
      hipchat_reviewer = event.reviewer.hipchat_username

      unless hipchat_author.blank?
        message  = "@#{hipchat_author} your commit has been rejected by #{hipchat_reviewer}: "
        message << "https://github.com/#{commit.repository.to_s}/commit/#{commit.sha}"
        hipchat_api.rooms_message(Figaro.env.hipchat_room, "GHCR", message, 1, 'red', 'text')
      end
    end

    def deliver_auto_accepted(commit, fixed_commits)
      return false if Figaro.env.hipchat_token.blank?

      hipchat_reviewers = fixed_commits.map { |_commit|
        _commit.events.where(status: 'rejected').last.try(:reviewer).try(:hipchat_username)
      }.compact

      unless hipchat_reviewers.blank?
        message  = "@#{hipchat_reviewers.join(', @')} this commit made some fixes:"
        message << "https://github.com/#{commit.repository.to_s}/commit/#{commit.sha}"
        hipchat_api.rooms_message(Figaro.env.hipchat_room, "GHCR", message, 1, 'green', 'text')
      end
    end

    def hipchat_api
      @hipchat_api ||= HipChat::API.new(Figaro.env.hipchat_token)
    end
  end
end
