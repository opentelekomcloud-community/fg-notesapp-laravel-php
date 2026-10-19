<?php

use App\Http\Middleware\AssignRequestId;
use App\Http\Middleware\HandleInertiaRequests;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\AddLinkHeadersForPreloadedAssets;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Symfony\Component\HttpFoundation\Response;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // FunctionGraph sits behind API Gateway, which terminates TLS.
        $middleware->trustProxies(at: '*');
        $middleware->append(AssignRequestId::class);

        $middleware->web(append: [
            HandleInertiaRequests::class,
            AddLinkHeadersForPreloadedAssets::class,
        ]);

        //
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => ! $request->header('X-Inertia')
                && ($request->is('api/*') || $request->expectsJson()),
        );

        $exceptions->respond(function (Response $response, Throwable $e, Request $request) {
            if (! $request->header('X-Inertia')) {
                return $response;
            }

            $status = $response->getStatusCode();

            if ($status === 419) {
                return back()->with('error', 'The page expired, please try again.');
            }

            if (in_array($status, [403, 404, 500, 503]) && ! config('app.debug')) {
                return Inertia::render('Error', ['status' => $status])
                    ->toResponse($request)
                    ->setStatusCode($status);
            }

            return $response;
        });
    })->create();
