Marcov-2ch-bot
=====================================

Description
-----------

Marcov-2ch-bot is an tiny Twitter Bot was made by way of trial Markov algorithm.

Installation
------------

### Dependency Mecab (Ubuntu 10.10)

    $ sudo apt-get install mecab libmecab-dev mecab-ipadic
    $ sudo /usr/lib/mecab/mecab-dict-index -d /usr/share/mecab/dic/ipadic -o /var/lib/mecab/dic/ipadic -f euc-jp -t utf-8 -p

    $ wget http://sourceforge.net/projects/mecab/files/mecab-ruby/0.97/mecab-ruby-0.97.tar.gz
    $ tar xof mecab-ruby-0.97.tar.gz 
    $ cd mecab-ruby-0.97/
    $ ruby extconf.rb 
    $ make
    $ make install

### Ruby

    $ rvm use 1.9.2
    $ rvm gemset create markov-2ch-bot
    $ gem install bundle
    $ bundle

Usage
------------

    1. Pass arguments --env [development|production]
    2. Configure Twitter OAuth information in config/bot.yaml
    3. Set cron 

    0,30 * * * * /bin/bash -l -c 'cd /path/to/markov-2ch-bot/bin && ruby bot.rb -c markov_tweet -e production'
