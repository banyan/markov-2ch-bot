%w(
  active_support/core_ext
  active_support/dependencies
  active_support/cache
).each { |lib| require lib }

%w(
  markov
  nichan
  twitter-bot
).each { |name| require_dependency File.expand_path("../markov-2ch-bot/#{name}", __FILE__) }
