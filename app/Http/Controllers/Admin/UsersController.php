<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
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
            ->select(['id', 'name', 'email'])
            ->orderBy('name')
            ->paginate(25)
            ->through(static fn (User $user): array => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'isAdmin' => in_array(strtolower($user->email), $adminEmails, true),
                'isOnline' => in_array($user->id, $onlineUserIds, true),
            ]);

        return Inertia::render('Admin/Users/Index', [
            'users' => $users,
        ]);
    }
}
