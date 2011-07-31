# -*- coding: utf-8 -*-

require 'open-uri'

module Markov2chBot
  class Nichan
    def initialize(options = {})
      @url = options[:url] || "http://hibari.2ch.net/news4vip/subject.txt"
    end

    def get_thread_list
      text  = ""
      open(@url, "r:SJIS") do |line|
        text = line.read.encode("utf-8", invalid: :replace, undef: :replace)
        text = text.gsub(/^\d+\.dat<>/, "")
        text = text.gsub(/\(\d+\)$/, "")
      end
      text.split("\n")
    end
  end
end
