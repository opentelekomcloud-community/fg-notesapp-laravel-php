<?php

namespace Tests\Feature;

use App\Models\Note;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class NoteTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_update_and_delete_a_note(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->post('/notes', ['title' => 'First', 'body' => 'Hello'])
            ->assertRedirect('/notes');

        $note = $user->notes()->firstOrFail();

        $this->actingAs($user)
            ->put("/notes/{$note->id}", ['title' => 'Updated', 'body' => 'Changed'])
            ->assertRedirect('/notes');
        $this->assertSame('Updated', $note->fresh()->title);

        $this->actingAs($user)->delete("/notes/{$note->id}")->assertRedirect('/notes');
        $this->assertModelMissing($note);
    }

    public function test_user_cannot_access_another_users_note(): void
    {
        $note = Note::factory()->create();
        $other = User::factory()->create();

        $this->actingAs($other)->get("/notes/{$note->id}/edit")->assertForbidden();
        $this->actingAs($other)->put("/notes/{$note->id}", ['title' => 'x'])->assertForbidden();
        $this->actingAs($other)->delete("/notes/{$note->id}")->assertForbidden();
    }

    public function test_title_is_required(): void
    {
        $this->actingAs(User::factory()->create())
            ->post('/notes', ['title' => ''])
            ->assertSessionHasErrors('title');
    }
}
