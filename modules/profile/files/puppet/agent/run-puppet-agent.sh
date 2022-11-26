#!/bin/sh

if [ -f /etc/profile.d/puppet-agent.sh ]; then
    . /etc/profile.d/puppet-agent.sh
fi

# TODO: wait for last run to finish

puppet agent --onetime --no-daemonize --verbose --no-splay --show_diff --no-usecacheonfailure
