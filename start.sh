#!/bin/bash

set -e

/usr/share/ovn/scripts/ovn-ctl --db-nb-create-insecure-remote=yes --db-sb-create-insecure-remote=yes start_ovsdb
/usr/bin/ovn-northd -vconsole:info --ovnnb-db=unix:/var/run/ovn/ovnnb_db.sock --ovnsb-db=unix:/var/run/ovn/ovnsb_db.sock --no-chdir --log-file=/dev/console --pidfile=/var/run/ovn/ovn-northd.pid --monitor
