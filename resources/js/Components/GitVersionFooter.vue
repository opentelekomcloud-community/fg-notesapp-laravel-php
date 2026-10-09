<script setup>
const gitCommit = __GIT_COMMIT__;
const gitVersion = gitCommit.slice(0, 7);
</script>

<template>
    <footer class="w-full px-4 py-4 text-center text-xs text-gray-500">
        Git
        <a
            :href="`https://github.com/opentelekomcloud-community/fg-notesapp-laravel-php/tree/${gitCommit}`"
            target="_blank"
            rel="noopener noreferrer"
            :aria-label="`View Git commit ${gitVersion} on GitHub (opens in a new tab)`"
            class="underline underline-offset-2 hover:text-gray-700 focus-visible:rounded-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-gray-500"
        >
            {{ gitVersion }}
        </a>
    </footer>
</template>