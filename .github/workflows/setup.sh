#!/bin/sh

set -e
set -x

sudo apt install ruby pandoc
sudo gem install cri
sudo gem install nanoc --version 3.8.0
sudo gem install pandoc-ruby nokogiri

# Latest versions of ruby do not allow Date class to be parsed by default, and
# spit out lots of warnings from the nanoc 3.8.0 use of ERB, so until we have
# enough time to do a full upgrade, just patch it up.
sudo sed -i -e 's/YAML.load(pieces\[2\])/YAML.load(pieces[2], permitted_classes: [Date])/' /var/lib/gems/*/gems/nanoc-3.8.0/lib/nanoc/data_sources/filesystem.rb
sudo sed -i -e '/ERB.new/s/(content, safe_level, trim_mode)/(content, trim_mode: trim_mode)/' /var/lib/gems/*/gems/nanoc-3.8.0/lib/nanoc/filters/erb.rb
