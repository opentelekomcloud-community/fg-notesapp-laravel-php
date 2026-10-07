<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function __invoke(Request $request): Response
    {
        $user = $request->user();

        return Inertia::render('Dashboard', [
            'stats' => [
                'notes' => $user->notes()->count(),
                'pinned' => $user->notes()->where('pinned', true)->count(),
            ],
            'recentNotes' => $user->notes()
                ->latest('updated_at')
                ->orderByDesc('id')
                ->limit(5)
                ->get(['id', 'title', 'pinned', 'updated_at']),
        ]);
    }
}
