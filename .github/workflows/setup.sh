#!/bin/sh

set -e
set -x

sudo apt install ruby pandoc
sudo gem install cri -v 2.10.1
sudo gem install nanoc --version 3.8.0
sudo gem install pandoc-ruby nokogiri
