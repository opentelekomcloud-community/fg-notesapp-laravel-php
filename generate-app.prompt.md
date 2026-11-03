# Build a Personal Notes App

Create a complete, production-minded notes application with the functionality and deployment shape described below. Implement the working application, not a mockup or a plan. Follow the repository's existing conventions and inspect installed dependency versions before relying on framework APIs. Do not replace or remove unrelated user work.

## Product

Build a private, account-based notes app. Each person can manage only their own notes. Include a dashboard, note library, profile management, authentication, and an email-allowlisted admin area for account management. Use a responsive, calm interface optimized for scanning and writing, with clear empty, loading/submission, validation, success, and error states. Keep the authenticated navigation usable on mobile.

## Technology

- PHP 8.3+ and Laravel 13.
- Inertia.js v2 with Vue 3, Vite, and the project's existing Tailwind setup.
- Laravel Breeze-style session authentication and Ziggy named-route helpers.
- PostgreSQL in the production container; SQLite may be used by tests.
- Follow existing project dependencies and avoid adding packages unless they are genuinely necessary.

## Required Features

### Authentication and profile

- Provide registration, login/logout, email verification, password confirmation, password reset, and password update flows.
- Require authentication and verified email for the dashboard, notes, and admin area. Profile editing remains available to authenticated users.
- Allow users to update their name and email, change their password, and delete their own account with password confirmation.
- Record `last_login_at` on successful login.

### Notes

- Users can create, view, edit, pin/unpin, and delete notes. A note has a required title (maximum 255 characters), optional text body, a pinned flag, and timestamps.
- Enforce note ownership on every read and mutation; never trust a client-supplied user ID. Return forbidden for attempts to access another user's note.
- The notes page lists only the current user's notes, pinned notes first and then most recently updated. Paginate 12 per page and retain query parameters across pages.
- Support case-insensitive partial search over title and body, with a short debounce in the UI and useful no-notes/no-search-results states.
- Show a readable body excerpt, updated timestamp, and clear edit, pin, and delete actions. Confirm destructive note deletion.
- Validate all input server-side and display field-level validation errors.

### Dashboard

- Show the current user's total note count and pinned-note count.
- Show their five most recently updated notes, with links to edit and to the full notes list.
- Provide a useful first-note empty state and a prominent create-note action.

### Admin user management

- Gate admin access on configured email addresses from `ADMIN_EMAILS`, a comma-separated environment value. Normalize addresses consistently (trim and lowercase); do not hard-code administrator accounts.
- Expose an admin user list with name, email, role, last login (or “Never”), and online/offline status. Mark a user online when a database-backed session has activity within the last five minutes. Paginate 25 users per page.
- Do not expose the admin route or delete endpoint to non-admin users, even if they submit requests directly.
- Let an admin delete another account only after an explicit confirmation modal. Prevent self-deletion. Deleting an account must remove its sessions and cascade-delete its notes in a transaction, then show a success message.
- Do not leak passwords, remember tokens, or other sensitive account data to Inertia props.

## Data and Security

- Users have a nullable datetime `last_login_at`.
- Notes belong to users with a cascading foreign key and have a database index suitable for per-user pinned/recent-note queries.
- Use Laravel policies/authorization for note ownership, form validation, CSRF protection, named routes, and database transactions for multi-step destructive operations.
- Configure database-backed sessions in the production deployment, since online-user status depends on session records.
- Keep credentials and deployment secrets in environment variables. Never place secrets in source, images, or generated frontend assets.

## Interface Details

- Provide authenticated navigation to Dashboard and Notes; show Users only to admins. Include Profile and Log Out controls.
- Give each page a clear title, consistent spacing and controls, accessible labels/focus states, and responsive layouts.
- Use semantic tables for the admin list with horizontal overflow support on narrow screens. Clearly distinguish admin/user roles and online/offline status without color alone.
- Make confirmation dialogs keyboard accessible, prevent dismissal while a deletion request is processing, and identify the account being deleted.
- Display a small build/version footer. Embed the Git commit hash at frontend build time when available; render a graceful fallback for local builds without it.
- Preserve established project branding where available, including the FunctionGraph documentation logo/link if present.

## Deployment and Operations

- Provide a multi-stage Docker build that installs production Composer dependencies and builds frontend assets, then runs a non-root PHP 8.3 application container listening on `0.0.0.0:8000`.
- Support PostgreSQL through `pdo_pgsql`, database-backed sessions/cache, and configurable startup migrations. Do not bake runtime environment values into the image.
- Pass the Git commit hash as a Docker build argument for the footer. Keep the container compatible with Huawei Cloud FunctionGraph's HTTP container runtime.
- Keep existing Makefile workflows for image build, local run, and push to the configured Open Telekom Cloud Software Repository for Containers; consume registry credentials only from environment variables.

## Verification and Acceptance Criteria

- Add/update PHPUnit feature tests covering note create/update/delete, required-title validation, note ownership denial, dashboard counts/recent notes/empty state, last-login updates, admin allowlist authorization, online threshold and last-login display, admin pagination, deletion cascade/session cleanup, and prevention of self-deletion.
- Verify guest and unverified-user access behavior for protected routes.
- Run the narrow relevant PHPUnit tests, the full test suite when practical, PHP formatting with Pint, and `npm run build`.
- Confirm routes render the correct Inertia pages and that the app starts through the documented local workflow.
- Keep changes focused, follow Laravel and Inertia conventions, and report what was implemented plus any checks that could not be run.
