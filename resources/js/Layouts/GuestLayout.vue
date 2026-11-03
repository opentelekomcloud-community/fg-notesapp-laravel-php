<script setup>
import ApplicationLogo from '@/Components/ApplicationLogo.vue';
import GitVersionFooter from '@/Components/GitVersionFooter.vue';
import { Link } from '@inertiajs/vue3';
</script>

<template>
    <div
        class="flex min-h-screen flex-col items-center bg-gray-100 pt-6"
    >
        <div class="flex w-full flex-1 flex-col items-center sm:justify-center">
            <div class="text-2xl font-bold">Notes App</div>
            <div
                class="mt-6 w-full overflow-hidden bg-white px-6 py-4 shadow-md sm:max-w-md sm:rounded-lg"
            >
                <slot />
            </div>
        </div>
        <GitVersionFooter />
    </div>
</template>
