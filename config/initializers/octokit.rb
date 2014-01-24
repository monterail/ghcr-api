Octokit.configure do |c|
  c.faraday_config do |builder|
    builder.response(:logger, Rails.logger) if Rails.env.development?
    builder.use Faraday::HttpCache, store: Rails.cache, logger: Rails.logger, shared_cache: false, serializer: YAML
  end
end
