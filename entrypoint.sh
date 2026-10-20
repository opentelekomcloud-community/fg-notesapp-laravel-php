#!/bin/sh

set -e

# FunctionGraph ignores WORKDIR, so use absolute paths.
cd /app
mkdir -p /tmp/views

# --isolated needs the cache_locks table; fall back to a plain migrate on the very first deploy.
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    php /app/artisan migrate --force --isolated || php /app/artisan migrate --force
fi

# cache Laravel configuration, routes, views, and events
php /app/artisan optimize --no-interaction

exec php /app/artisan serve --host=0.0.0.0 --port=8000 --no-reload
