<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import { Head, Link } from '@inertiajs/vue3';
import { ArrowRight, FileText, Pin, Plus } from '@lucide/vue';

defineProps({
    stats: Object,
    recentNotes: Array,
});

const formatDate = (value) =>
    new Date(value).toLocaleString(undefined, {
        dateStyle: 'medium',
        timeStyle: 'short',
    });
</script>

<template>
    <AuthenticatedLayout>
        <Head title="Dashboard" />

        <template #header>
            <div class="flex flex-wrap items-center justify-between gap-4">
                <h2 class="text-xl font-semibold leading-tight text-gray-800">
                    Dashboard
                </h2>
                <Link :href="route('notes.create')">
                    <PrimaryButton>
                        <Plus class="h-4 w-4" aria-hidden="true" />
                        <span>New note</span>
                    </PrimaryButton>
                </Link>
            </div>
        </template>

        <div class="py-8">
            <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                <dl class="grid grid-cols-2 gap-6 border-y border-gray-200 py-6">
                    <div>
                        <dt class="flex items-center gap-2 text-sm text-gray-600">
                            <FileText class="h-5 w-5 text-sky-600" aria-hidden="true" />
                            Total notes
                        </dt>
                        <dd class="mt-2 text-3xl font-semibold text-gray-900">
                            {{ stats.notes }}
                        </dd>
                    </div>
                    <div>
                        <dt class="flex items-center gap-2 text-sm text-gray-600">
                            <Pin class="h-5 w-5 text-amber-600" aria-hidden="true" />
                            Pinned notes
                        </dt>
                        <dd class="mt-2 text-3xl font-semibold text-gray-900">
                            {{ stats.pinned }}
                        </dd>
                    </div>
                </dl>

                <section class="mt-8" aria-labelledby="recent-notes-heading">
                    <div class="flex flex-wrap items-center justify-between gap-4">
                        <h3 id="recent-notes-heading" class="text-lg font-semibold text-gray-900">
                            Recent notes
                        </h3>
                        <Link
                            :href="route('notes.index')"
                            class="inline-flex items-center gap-2 rounded-md text-sm font-medium text-indigo-600 hover:text-indigo-800 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                        >
                            View all notes
                            <ArrowRight class="h-4 w-4" aria-hidden="true" />
                        </Link>
                    </div>

                    <ul v-if="recentNotes.length" class="mt-4 divide-y divide-gray-200 border-y border-gray-200">
                        <li v-for="note in recentNotes" :key="note.id">
                            <Link
                                :href="route('notes.edit', note.id)"
                                class="flex items-center gap-3 py-4 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
                            >
                                <FileText class="h-5 w-5 shrink-0 text-gray-400" aria-hidden="true" />
                                <div class="min-w-0 flex-1">
                                    <p class="break-words font-medium text-gray-900">
                                        {{ note.title }}
                                    </p>
                                    <time :datetime="note.updated_at" class="mt-1 block text-sm text-gray-500">
                                        {{ formatDate(note.updated_at) }}
                                    </time>
                                </div>
                                <span v-if="note.pinned" class="shrink-0 text-amber-600" title="Pinned">
                                    <Pin class="h-4 w-4" aria-hidden="true" />
                                    <span class="sr-only">Pinned</span>
                                </span>
                                <ArrowRight class="h-4 w-4 shrink-0 text-gray-400" aria-hidden="true" />
                            </Link>
                        </li>
                    </ul>

                    <div v-else class="mt-4 border-y border-gray-200 py-12 text-center">
                        <FileText class="mx-auto h-8 w-8 text-gray-400" aria-hidden="true" />
                        <p class="mt-3 text-sm text-gray-600">No notes yet.</p>
                        <Link
                            :href="route('notes.create')"
                            class="mt-3 inline-flex items-center gap-2 rounded-md text-sm font-medium text-indigo-600 hover:text-indigo-800 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
                        >
                            <Plus class="h-4 w-4" aria-hidden="true" />
                            Create your first note
                        </Link>
                    </div>
                </section>
            </div>
        </div>
    </AuthenticatedLayout>
</template>