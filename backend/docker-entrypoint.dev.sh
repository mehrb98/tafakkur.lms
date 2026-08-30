#!/bin/bash
set -euo pipefail

cd /app

if [ "${RUN_DB_PREPARE:-true}" = "true" ] && [ -f bin/rails ]; then
    echo "==> Preparing database..."
    bundle exec rails db:prepare
fi

exec "$@"
