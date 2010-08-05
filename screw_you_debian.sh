#!/bin/sh

# screw_you_debian.sh: install a homedir copy of RubyGems if not present
# and set up relevant environment variables. If already present, just
# set up the env variables. Run this either from your .profile or
# from the command line as:
#
# . ./screw_you_debian.sh

set -e 

if [ ! -d $HOME/gems ]; then
    if [ -f $HOME/gems ]; then
        echo $HOME/gems already exists but is not a directory. Aborting to avoid overwriting it.
        exit 1
    fi

    PWD=`pwd`
    cd $HOME
    wget -O - http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz | tar -xzf -
    cd rubygems-1.3.7
    ruby setup.rb --prefix=$HOME/gems
    ln -sf $HOME/gems/bin/gem1.8 $HOME/gems/bin/gem
    cd ..
    rm -rf rubygems-1.3.7
    cd $PWD
fi

export PATH=$HOME/gems/bin:$PATH
export RUBYLIB=$HOME/gems/lib:$RUBYLIB
export GEM_HOME=$HOME/gems
