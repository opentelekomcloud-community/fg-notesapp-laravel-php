<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Inertia\Inertia;
use Inertia\Response;

class UsersController extends Controller
{
    public function __invoke(): Response
    {
        Gate::authorize('view-admin');

        $onlineUserIds = DB::table('sessions')
            ->whereNotNull('user_id')
            ->where('last_activity', '>=', now()->subMinutes(5)->timestamp)
            ->pluck('user_id')
            ->map(static fn ($userId): int => (int) $userId)
            ->all();
        $adminEmails = config('admin.emails', []);

        $users = User::query()
            ->select(['id', 'name', 'email', 'last_login_at'])
            ->orderBy('name')
            ->paginate(25)
            ->through(static fn (User $user): array => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'lastLoginAt' => $user->last_login_at?->toIso8601String(),
                'isAdmin' => in_array(strtolower($user->email), $adminEmails, true),
                'isOnline' => in_array($user->id, $onlineUserIds, true),
            ]);

        return Inertia::render('Admin/Users/Index', [
            'users' => $users,
        ]);
    }

    public function destroy(User $user): RedirectResponse
    {
        Gate::authorize('view-admin');

        abort_if(auth()->id() === $user->id, 403);

        DB::transaction(function () use ($user): void {
            DB::table('sessions')->where('user_id', $user->id)->delete();
            $user->delete();
        });

        return redirect()->route('admin.users.index')->with('success', 'User account deleted.');
    }
}
