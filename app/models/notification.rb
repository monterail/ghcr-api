class Notification
  HARDCODED_MAPPING = {
    "chytreg"         =>  "dariusz",
    "teamon"          =>  "tymon",
    "porada"          =>  "dominik",
    "bartoszpietrzak" =>  "bartosz",
    "szymo"           =>  "szymon",
    "tallica"         =>  "tallica",
    "marcinlerka"     =>  "marcin",
    "szajbus"         =>  "szajbus",
    "jcieslar"        =>  "JakubCieślar",
    "sheerun"         =>  "adam",
    "venticco"        =>  "KrzysztofJung",
    "jandudulski"     =>  "jan",
    "michlask"        =>  "MichalLaskowski",
    "ostrzy"          =>  "MichałDuda",
    "szkarol"         =>  "karol",
    "dmilith"         =>  "dmilith"
  }


  class << self
    def deliver_rejected(event)
      commit = event.commit
      username = commit.author.try(:username)
      hipchat_username = HARDCODED_MAPPING(username)
      hipchat_reviwer = HARDCODED_MAPPING(commit.reviewer.username)

      unless hipchat_username.blank?
        message  = "@#{hipchat_username} your commit has been rejected by #{hipchat_reviwer}:"
        message += "https://github.com/#{commit.repository.to_s}/commit/#{commit.sha}"
        hipchat_api.rooms_message(Figaro.env.hipchat_room, "GHCR", message, 1, 'red', 'text')
      end
    end

    def hipchat_api
      @hipchat_api ||= HipChat::API.new(Figaro.env.hipchat_token)
    end

  end
end
