# Container image for FunctionGraph (listens on port 8000, runs as UID/GID 1003).

FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader --ignore-platform-reqs

FROM node:22-bookworm-slim AS assets
WORKDIR /app
ARG GIT_COMMIT
ENV GIT_COMMIT=$GIT_COMMIT
COPY package.json package-lock.json .npmrc ./
RUN npm ci
COPY . .
# app.js imports Ziggy from vendor/
COPY --from=vendor /app/vendor ./vendor
RUN npm run build

FROM php:8.3-cli-alpine
RUN apk add --no-cache libpq \
    && apk add --no-cache --virtual .build-deps postgresql-dev \
    && docker-php-ext-install pdo_pgsql opcache \
    && apk del .build-deps
WORKDIR /app
COPY . .
COPY --from=vendor /app/vendor ./vendor
COPY --from=assets /app/public/build ./public/build
RUN chown -R 1003:1003 /app
USER 1003:1003

ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr \
    DB_CONNECTION=pgsql \
    DB_PORT=5432 \
    SESSION_DRIVER=cookie \
    CACHE_STORE=database \
    QUEUE_CONNECTION=sync \
    VIEW_COMPILED_PATH=/tmp/views \
    APP_SERVICES_CACHE=/tmp/services.php \
    APP_PACKAGES_CACHE=/tmp/packages.php \
    APP_CONFIG_CACHE=/tmp/config.php \
    APP_ROUTES_CACHE=/tmp/routes.php \
    APP_EVENTS_CACHE=/tmp/events.php \
    RUN_MIGRATIONS=true \
    PHP_CLI_SERVER_WORKERS=4

EXPOSE 8000
# FunctionGraph ignores WORKDIR, so use absolute paths.
# --isolated needs the cache_locks table; fall back to a plain migrate on the very first deploy.
CMD ["sh", "-c", "cd /app && mkdir -p /tmp/views && if [ \"${RUN_MIGRATIONS:-true}\" = \"true\" ]; then (php /app/artisan migrate --force --isolated || php /app/artisan migrate --force); fi && exec php /app/artisan serve --host=0.0.0.0 --port=8000 --no-reload"]
