<script setup>
import { Head, Link } from '@inertiajs/vue3';
import { computed } from 'vue';
import GitVersionFooter from '@/Components/GitVersionFooter.vue';

const props = defineProps({ status: Number });

const messages = {
    403: 'You are not allowed to access this page.',
    404: 'The page you are looking for could not be found.',
    500: 'Something went wrong on our servers.',
    503: 'The service is temporarily unavailable.',
};

const message = computed(() => messages[props.status] ?? 'An error occurred.');
</script>

<template>
    <Head :title="String(status)" />

    <div class="flex min-h-screen flex-col bg-gray-100 p-6">
        <main class="flex flex-1 flex-col items-center justify-center text-center">
            <h1 class="text-5xl font-bold text-gray-800">{{ status }}</h1>
            <p class="mt-4 text-gray-600">{{ message }}</p>
            <Link :href="route('notes.index')" class="mt-6 text-indigo-600 underline">
                Back to notes
            </Link>
        </main>
        <GitVersionFooter />
    </div>
</template>
