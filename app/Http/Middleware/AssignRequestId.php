<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AssignRequestId
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $requestId = $request->header('X-CFF-Request-Id') ?: (string) Str::uuid();
        $startedAt = hrtime(true);

        Log::shareContext([
            'request-id' => $requestId,
        ]);

        $response = $next($request);

        Log::info('HTTP access', [
            'method' => $request->method(),
            // 'path' => $request->path(),
            'status' => $response->getStatusCode(),
            'duration_ms' => round((hrtime(true) - $startedAt) / 1_000_000, 2),
        ]);

        $response->headers->set('Request-Id', $requestId);

        return $response;
    }
}
