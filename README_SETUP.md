# Notes App – Setup Guide

A note-taking application built with **Laravel 13**, **Inertia.js 2** and **Vue 3** (Laravel Breeze scaffolding, Tailwind CSS).

Features: user registration/login, create/edit/delete notes, pin notes, live search, pagination, per-user authorization.

---

## 1. Prerequisites (Ubuntu 22.04)

### PHP 8.3 and required extensions

Laravel 13 requires PHP >= 8.3.

```bash
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.3-cli php8.3-xml php8.3-mbstring php8.3-curl \
    php8.3-zip php8.3-bcmath php8.3-sqlite3 php8.3-pgsql
php -v   # should show 8.3.x
```

> `php8.3-pgsql` is required for PostgreSQL; `php8.3-sqlite3` is used by the test suite.

### Composer

```bash
composer -V
```

### Node.js >= 20.19 (Node 22 recommended)

Vite 8 does not run on older Node versions. Using nvm:

```bash
nvm install 22
nvm use 22
nvm alias default 22
node -v
```

## 2. Configuration

### Update `.env`

Use `.env.example` as starting point and copy
this file to `.env`.

```
cp .env.example .env
```

Adapt values to your needs.

To generate an APP_KEY use:

```
php artisan key:generate
```

`ADMIN_EMAILS` is a comma separated list of email addresses for admin users.


## 3. Build, Run, Test

### Run migration

Run the migration to setup database:

```bash
php artisan migrate
```


### Build and run

Production build:

```bash
npm run build
php artisan serve
```

Development (two terminals):

```bash
php artisan serve   # terminal 1  (note: php artisan, not "composer artisan")
npm run dev         # terminal 2  (Vite hot reload)
```

Or both at once: `composer run dev`.

Open http://localhost:8000, register an account, and start taking notes.

Laravel logs can be found in: [storage/logs/laravel.log](storage/logs/laravel.log)


---

### Tests

```bash
php artisan test
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `could not find driver (Connection: pgsql)` | `sudo apt install php8.3-pgsql` |
| `could not find driver (Connection: sqlite)` (tests) | `sudo apt install php8.3-sqlite3` |
| `requires php ^8.3` during `create-project` | Install PHP 8.3 (step 1) |
| `ext-xml` / `ext-dom` missing | `sudo apt install php8.3-xml` |
| Vite/rolldown crash on build | Use Node >= 20.19 (`nvm use 22`), then reinstall `node_modules` |
| `Could not resolve './bootstrap'` | Remove `import './bootstrap';` from `resources/js/app.js` |
| `Command "artisan" is not defined` | Use `php artisan serve`, not `composer artisan serve` |
