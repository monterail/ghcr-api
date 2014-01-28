class Notification
  class << self
    def deliver_rejected(event)
      return false unless hipchat_api?
      commit = event.commit
      hipchat_username = commit.author.try(:hipchat_username)
      hipchat_reviewer = event.reviewer.hipchat_username

      unless hipchat_username.blank?
        message  = "@#{hipchat_username} your commit has been rejected by #{hipchat_reviewer}: "
        message << "https://github.com/#{commit.repository.to_s}/commit/#{commit.sha}"
        hipchat_api.rooms_message(Figaro.env.hipchat_room, "GHCR", message, 1, 'red', 'text')
      end
    end

    def deliver_auto_accepted(commit)
      return false unless hipchat_api?
      hipchat_reviewers = Event.joins(:commit, :reviewer).
        where('events.status' => 'rejected').
        where('commits.repository_id' => commit.repository_id).
        where("commits.sha SIMILAR TO ?", "(#{commit.accepted_shas.join('|')})%").
        uniq.pluck('users.hipchat_username')

      unless hipchat_reviewers.blank?
        message  = "@#{hipchat_reviewers.join(', @')} this commit made some fixes:"
        message << "https://github.com/#{commit.repository.to_s}/commit/#{commit.sha}"
        hipchat_api.rooms_message(Figaro.env.hipchat_room, "GHCR", message, 1, 'green', 'text')
      end
    end

    def hipchat_api
      @hipchat_api ||= HipChat::API.new(Figaro.env.hipchat_token)
    end

    def hipchat_api?
      hipchat_api.token.present?
    end
  end
end
