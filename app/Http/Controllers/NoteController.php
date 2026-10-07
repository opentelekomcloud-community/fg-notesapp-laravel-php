<?php

namespace App\Http\Controllers;

use App\Models\Note;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Inertia\Inertia;
use Inertia\Response;

class NoteController extends Controller
{
    public function index(Request $request): Response
    {
        $search = trim((string) $request->query('search', ''));

        $notes = $request->user()->notes()
            ->when($search !== '', function ($query) use ($search) {
                $query->where(function ($q) use ($search) {
                    $q->whereLike('title', "%{$search}%")
                        ->orWhereLike('body', "%{$search}%");
                });
            })
            ->orderByDesc('pinned')
            ->latest('updated_at')
            ->paginate(12)
            ->withQueryString();

        return Inertia::render('Notes/Index', [
            'notes' => $notes,
            'filters' => ['search' => $search],
        ]);
    }

    public function create(): Response
    {
        return Inertia::render('Notes/Form');
    }

    public function store(Request $request): RedirectResponse
    {
        $request->user()->notes()->create($this->validated($request));

        return redirect()->route('notes.index')->with('success', 'Note created.');
    }

    public function edit(Note $note): Response
    {
        Gate::authorize('view', $note);

        return Inertia::render('Notes/Form', [
            'note' => $note->only('id', 'title', 'body', 'pinned', 'updated_at'),
        ]);
    }

    public function update(Request $request, Note $note): RedirectResponse
    {
        Gate::authorize('update', $note);

        $note->update($this->validated($request));

        return redirect()->route('notes.index')->with('success', 'Note updated.');
    }

    public function togglePin(Note $note): RedirectResponse
    {
        Gate::authorize('update', $note);

        $note->update(['pinned' => ! $note->pinned]);

        return back();
    }

    public function destroy(Note $note): RedirectResponse
    {
        Gate::authorize('delete', $note);

        $note->delete();

        return redirect()->route('notes.index')->with('success', 'Note deleted.');
    }

    private function validated(Request $request): array
    {
        return $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'body' => ['nullable', 'string', 'max:65535'],
            'pinned' => ['boolean'],
        ]);
    }
}
