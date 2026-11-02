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

---

## 2. Create the Laravel project

```bash
composer create-project laravel/laravel notes-app
cd notes-app
```

## 3. Install Breeze with Inertia + Vue

```bash
composer require laravel/breeze --dev
php artisan breeze:install vue
```

### Fix: remove the `bootstrap` import

Laravel 13 no longer ships `resources/js/bootstrap.js`, but Breeze still imports it. Remove this line from `resources/js/app.js`:

```js
import './bootstrap';
```

If `npm install` ran under an old Node version, reinstall:

```bash
rm -rf node_modules package-lock.json
npm install
```

---

## 4. Notes feature

### 4.1 Generate model, migration, factory and policy

```bash
php artisan make:model Note -mf
php artisan make:policy NotePolicy --model=Note
```

### 4.2 Migration – `database/migrations/xxxx_create_notes_table.php`

```php
Schema::create('notes', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('title');
    $table->text('body')->nullable();
    $table->boolean('pinned')->default(false);
    $table->timestamps();

    $table->index(['user_id', 'pinned', 'updated_at']);
});
```

### 4.3 Model – `app/Models/Note.php`

```php
#[Fillable(['title', 'body', 'pinned'])]
class Note extends Model
{
    use HasFactory;

    protected function casts(): array
    {
        return ['pinned' => 'boolean'];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

Add the relation to `app/Models/User.php`:

```php
public function notes(): HasMany
{
    return $this->hasMany(Note::class);
}
```

### 4.4 Factory – `database/factories/NoteFactory.php`

```php
return [
    'user_id' => User::factory(),
    'title' => fake()->sentence(4),
    'body' => fake()->paragraphs(3, true),
    'pinned' => false,
];
```

### 4.5 Policy – `app/Policies/NotePolicy.php`

Only the owner may view, update or delete a note:

```php
public function view(User $user, Note $note): bool   { return $note->user_id === $user->id; }
public function update(User $user, Note $note): bool { return $note->user_id === $user->id; }
public function delete(User $user, Note $note): bool { return $note->user_id === $user->id; }
```

### 4.6 Controller – `app/Http/Controllers/NoteController.php`

Actions: `index` (search + pinned-first + pagination), `create`, `store`, `edit`, `update`, `togglePin`, `destroy`. Every action on an existing note calls `Gate::authorize(...)`, and input is validated:

```php
$request->validate([
    'title' => ['required', 'string', 'max:255'],
    'body' => ['nullable', 'string', 'max:65535'],
    'pinned' => ['boolean'],
]);
```

See the file for the full implementation.

### 4.7 Routes – `routes/web.php`

Replace the default dashboard route with:

```php
use App\Http\Controllers\NoteController;

Route::redirect('/dashboard', '/notes')->name('dashboard');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('notes', NoteController::class)->except('show');
    Route::patch('/notes/{note}/pin', [NoteController::class, 'togglePin'])->name('notes.pin');
});
```

### 4.8 Share flash messages – `app/Http/Middleware/HandleInertiaRequests.php`

```php
'flash' => [
    'success' => fn () => $request->session()->get('success'),
],
```

### 4.9 Vue pages

- `resources/js/Pages/Notes/Index.vue` – note grid, debounced search, pin toggle, delete, pagination.
- `resources/js/Pages/Notes/Form.vue` – shared create/edit form using Inertia `useForm`.
- `resources/js/Layouts/AuthenticatedLayout.vue` – replace the "Dashboard" nav links with `route('notes.index')` / label "Notes".
- Delete the unused `resources/js/Pages/Dashboard.vue`.

### 4.10 Feature tests – `tests/Feature/NoteTest.php`

Covers CRUD, ownership (403 for other users) and validation.

---

## 5. Database (PostgreSQL)

Create a database and user:

```bash
sudo -u postgres psql -c "CREATE USER notes WITH PASSWORD 'secret';"
sudo -u postgres psql -c "CREATE DATABASE notes OWNER notes;"
```

Update `.env`:

```dotenv
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=notes
DB_USERNAME=notes
DB_PASSWORD=secret
```

Then run the migrations:

```bash
php artisan migrate
```

Note search uses `whereLike`, which is case-insensitive on PostgreSQL (`ILIKE`).

---

## 6. Build and run

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

---

## 7. Tests

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
