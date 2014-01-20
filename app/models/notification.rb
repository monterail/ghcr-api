class Notification
  class << self
    def deliver_rejected(event)
      return false if Figaro.env.hipchat_token.blank?
      commit = event.commit
      hipchat_username = commit.author.try(:hipchat_username)
      hipchat_reviewer = event.reviewer.hipchat_username

      unless hipchat_username.blank?
        message  = "@#{hipchat_username} your commit has been rejected by #{hipchat_reviewer}: "
        message << "https://github.com/#{commit.repository.to_s}/commit/#{commit.sha}"
        hipchat_api.rooms_message(Figaro.env.hipchat_room, "GHCR", message, 1, 'red', 'text')
      end
    end

    def hipchat_api
      @hipchat_api ||= HipChat::API.new(Figaro.env.hipchat_token)
    end
  end
end
