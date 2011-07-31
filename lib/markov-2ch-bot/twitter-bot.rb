# -*- coding: utf-8 -*-

require 'twitter'
require 'logger'
require 'yaml'
require 'pp'

module Markov2chBot
  class TwitterBot
    include Twitter

    def initialize(options)
      env = options[:env]
      yml = YAML::load(File.open("#{APP_ROOT}/config/bot.yaml"))
      Twitter.configure do |config|
        config.consumer_key       = yml[env]["consumer_key"]
        config.consumer_secret    = yml[env]["consumer_secret"]
        config.oauth_token        = yml[env]["oauth_token"]
        config.oauth_token_secret = yml[env]["oauth_token_secret"]
      end

      @client         = Twitter::Client.new
      @logger         = Logger.new("#{APP_ROOT}/log/#{env}.log", 5)
      @since_id_dat   = "#{APP_ROOT}/db/#{env}/since_id.dat"
      @regular_tweets = "#{APP_ROOT}/templates/#{env}/regular.txt"
      @reply_tweets   = "#{APP_ROOT}/templates/#{env}/reply.txt"
    end

    def tweet
      begin
        message = open(@regular_tweets).readlines.shuffle.first
        @client.update(message)
        @logger.info("tweeted: #{message.chomp}")
      rescue => e
        @logger.error e.message
      end
    end

    def reply
      load
      begin
        if @last_mentioned_id == -1
          opts = { :count => 200 }
        else
          opts = {
            :since_id => @last_mentioned_id,
            :count    => 200
          }
        end
        mentions = @client.mentions(opts)
        return if mentions.empty?
        mentions.each do |mention|
          message = open(@reply_tweets).readlines.shuffle.first
          @client.update("@#{mention.user.screen_name} message")
          @logger.info("replied to #{mention.user.screen_name}: #{message.chomp}")
        end
        @last_mentioned_id = mentions.first.id.to_s
        @logger.info("set since_id to #{@last_mentioned_id}")
      rescue => e
        @logger.error e.message
      end
      save
    end

    def markov_tweet
      begin
        nichan = Markov2chBot::Nichan.new
        markov = Markov2chBot::Markov.new({:texts => nichan.get_thread_list})
        markov.create_table
        message = markov.summarize
        @client.update(message)
        @logger.info("markov_tweeted: #{message.chomp}")
      rescue => e
        @logger.error e.message
      end
    end

    def follow_and_remove
      friends   = []
      followers = []

      @client.friends.users.each do |u|
        friends << u.id
      end

      @client.followers.users.each do |u|
        followers << u.id
      end

      # auto follow
      diff = followers - friends
      diff.each do |id|
        if @client.user?(id)
          begin
            @client.friendship_create(id)
            @logger.info("follow #{id.to_s}")
          rescue => e
            @logger.error e.message
          end
        end
      end

      # auto remove
      diff = friends - followers
      diff.each do |id|
        if @client.user?(id)
          begin
            @client.friendship_destroy(id)
            @logger.info("remove #{id.to_s}")
          rescue => e
            @logger.error e.message
          end
        end
      end
    end

    private
    def load
      begin
        open(@since_id_dat, "r") do |f|
          rows = f.readlines
          if rows.empty?
            @last_mentioned_id = -1
          else
            @last_mentioned_id = rows[0].to_i
          end
        end
      rescue => e
        @logger.error "file load error"
      end
    end

    def save
      begin
        open(@since_id_dat, "w") do |f|
          f.puts @last_mentioned_id
        end
      rescue => e
        @logger.error "file save error"
      end
    end
  end
end
