# -*- coding: utf-8 -*-

require 'MeCab'

module Markov2chBot
  class Markov
    def initialize(options = {})
      @texts = options[:texts]
      @mecab = MeCab::Tagger.new("-Owakati")
      @dict  = []
    end

    def create_table
      @texts.each do |text|
        @mecab.parse(text + "EOS").split(" ").each_cons(3) do |a| 
          @dict.push( {'head' => a[0], 'middle' => a[1], 'end' => a[2]} )
        end
      end
    end

    # TODO change behaivor always starting @dict[0]
    def summarize
      head     = @dict[0]['head']
      middle   = @dict[0]['middle']
      new_text = head + middle
      while true
        _a = []
        @dict.each do |hash|
          _a.push hash if hash['head'] == head && hash['middle'] == middle
        end 
       
        break if _a.size == 0
        num = rand(_a.size)
        #p num unless num == 0
        new_text = new_text + _a[num]['end']
        # puts new_text
        break if _a[num]['end'] == "EOS"
        head   = _a[num]['middle']
        middle = _a[num]['end']
      end
      new_text.gsub!(/EOS$/,'')
    end
  end
end
