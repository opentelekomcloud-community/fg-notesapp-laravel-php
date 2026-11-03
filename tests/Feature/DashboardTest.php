<?php

namespace Tests\Feature;

use App\Models\Note;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Sequence;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Inertia\Testing\AssertableInertia as Assert;
use Tests\TestCase;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_guests_are_redirected_to_login(): void
    {
        $response = $this->get('/dashboard');

        $response->assertRedirect(route('login'));
    }

    public function test_dashboard_is_empty_for_a_user_without_notes(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user)->get('/dashboard');

        $response->assertInertia(fn (Assert $page) => $page
            ->component('Dashboard')
            ->where('stats.notes', 0)
            ->where('stats.pinned', 0)
            ->has('recentNotes', 0)
        );
    }

    public function test_dashboard_shows_only_the_users_counts_and_five_most_recent_notes(): void
    {
        $this->freezeTime();
        $user = User::factory()->create();
        $notes = Note::factory()->for($user)->count(6)
            ->sequence(fn (Sequence $sequence): array => [
                'updated_at' => now()->subDays($sequence->index),
                'pinned' => $sequence->index === 0,
            ])
            ->create();
        Note::factory()->create([
            'pinned' => true,
            'updated_at' => now()->addDay(),
        ]);

        $response = $this->actingAs($user)->get('/dashboard');

        $response->assertInertia(fn (Assert $page) => $page
            ->component('Dashboard')
            ->where('stats.notes', 6)
            ->where('stats.pinned', 1)
            ->has('recentNotes', 5)
            ->where('recentNotes.0.id', $notes[0]->id)
            ->where('recentNotes.1.id', $notes[1]->id)
            ->where('recentNotes.2.id', $notes[2]->id)
            ->where('recentNotes.3.id', $notes[3]->id)
            ->where('recentNotes.4.id', $notes[4]->id)
        );
    }
}
