Octokit.middleware = Faraday::Builder.new do |builder|
  builder.response(:logger, Rails.logger) if Rails.env.development?
  builder.use Faraday::HttpCache, store: Rails.cache, logger: Rails.logger, shared_cache: false, serializer: Yajl
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
