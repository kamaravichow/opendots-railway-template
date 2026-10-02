#!/bin/sh
# Railway mounts volumes as root-owned. Fix the data directory, then drop to the
# unprivileged `node` user so the app never runs as root.
set -eu

if [ "$(id -u)" = "0" ]; then
  data_dir="$(dirname "${DATABASE_PATH:-/data/opendots.sqlite}")"
  mkdir -p "$data_dir"
  chown node:node "$data_dir"
  exec setpriv --reuid=node --regid=node --init-groups "$@"
fi

exec "$@"
