#!/bin/sh

set -e

cd /app
mkdir -p /tmp/views /tmp/nginx/client_temp /tmp/nginx/fastcgi_temp \
    /tmp/nginx/proxy_temp /tmp/nginx/uwsgi_temp /tmp/nginx/scgi_temp

if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    php /app/artisan migrate --force --isolated || php /app/artisan migrate --force
fi

php /app/artisan optimize --no-interaction

exec /usr/bin/supervisord -c /etc/supervisord.conf
