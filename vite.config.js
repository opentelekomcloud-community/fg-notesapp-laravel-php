import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';
import { execFileSync } from 'node:child_process';

function getGitCommit() {
    if (process.env.GIT_COMMIT) {
        return process.env.GIT_COMMIT;
    }

    try {
        return execFileSync('git', ['rev-parse', 'HEAD'], {
            encoding: 'utf8',
        }).trim();
    } catch {
        return 'unknown';
    }
}

export default defineConfig({
    define: {
        __GIT_COMMIT__: JSON.stringify(getGitCommit()),
    },
    plugins: [
        laravel({
            input: 'resources/js/app.js',
            refresh: true,
        }),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
    ],
});
