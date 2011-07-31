#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'slop'

commands = %w(
  tweet
  reply
  markov_tweet
  follow_and_remove
)

envelopments = %w(
  development
  production
)

argv = ARGV.dup
opts = Slop.parse! argv, :help => true do
  banner "Usage: bot.rb [options]"
  on :c, :command, "Invoke an command - required #{commands}", true
  on :e, :env,     "Set envelopment   - optional #{envelopments}", true
end
unless (opts.command? and commands.include?(opts[:command]))
  puts opts.help
  exit
end
options = opts.to_hash(true)
options[:env] = envelopments.include?(opts[:env]) ? opts[:env] : "development"
options.delete(:help)

require 'pathname'

APP_ROOT = Pathname.new(__FILE__).realpath.parent.parent
$LOAD_PATH.unshift APP_ROOT.join('lib') if $0 == __FILE__

require 'markov-2ch-bot'

bot = Markov2chBot::TwitterBot.new(options)
bot.send options[:command]
