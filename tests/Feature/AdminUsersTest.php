<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class AdminUsersTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_list_all_accounts_and_see_recent_activity(): void
    {
        $this->freezeTime();
        config(['admin.emails' => ['admin@example.com']]);

        $admin = User::factory()->create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
            'last_login_at' => now()->subDay(),
        ]);
        $idleUser = User::factory()->create([
            'name' => 'Idle User',
            'email' => 'idle@example.com',
        ]);
        $onlineUser = User::factory()->create([
            'name' => 'Online User',
            'email' => 'online@example.com',
        ]);

        DB::table('sessions')->insert([
            [
                'id' => 'idle-session',
                'user_id' => $idleUser->id,
                'payload' => '',
                'last_activity' => now()->subMinutes(6)->timestamp,
            ],
            [
                'id' => 'online-session',
                'user_id' => $onlineUser->id,
                'payload' => '',
                'last_activity' => now()->subMinutes(4)->timestamp,
            ],
        ]);

        $this->actingAs($admin)
            ->get(route('admin.users.index'))
            ->assertInertia(fn (Assert $page) => $page
                ->component('Admin/Users/Index')
                ->where('canViewAdmin', true)
                ->has('users.data', 3)
                ->where('users.data.0.name', 'Admin User')
                ->where('users.data.0.isAdmin', true)
                ->where('users.data.0.lastLoginAt', now()->subDay()->toIso8601String())
                ->where('users.data.1.name', 'Idle User')
                ->where('users.data.1.isAdmin', false)
                ->where('users.data.1.lastLoginAt', null)
                ->where('users.data.1.isOnline', false)
                ->where('users.data.2.name', 'Online User')
                ->where('users.data.2.isAdmin', false)
                ->where('users.data.2.isOnline', true)
            );
    }

    public function test_guests_are_redirected_from_admin_users_page(): void
    {
        $this->get(route('admin.users.index'))
            ->assertRedirect(route('login'));
    }

    public function test_users_not_on_the_admin_allowlist_are_forbidden(): void
    {
        config(['admin.emails' => ['admin@example.com']]);

        $this->actingAs(User::factory()->create())
            ->get(route('admin.users.index'))
            ->assertForbidden();
    }
}
