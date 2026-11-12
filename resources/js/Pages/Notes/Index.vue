<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, Link, router, usePage } from '@inertiajs/vue3';
import { Pin, Plus } from '@lucide/vue';
import { computed, ref, watch } from 'vue';

const props = defineProps({
    notes: Object,
    filters: Object,
});

const flash = computed(() => usePage().props.flash?.success);
const flashError = computed(() => usePage().props.flash?.error);
const search = ref(props.filters.search ?? '');

let timer;
watch(search, (value) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
        router.get(
            route('notes.index'),
            { search: value || undefined },
            { preserveState: true, replace: true },
        );
    }, 300);
});

const togglePin = (note) =>
    router.patch(route('notes.pin', note.id), {}, { preserveScroll: true });

const destroy = (note) => {
    if (confirm(`Delete "${note.title}"?`)) {
        router.delete(route('notes.destroy', note.id), { preserveScroll: true });
    }
};

const excerpt = (text) =>
    text && text.length > 160 ? text.slice(0, 160) + '…' : text;

const formatDate = (value) => new Date(value).toLocaleString();
</script>

<template>
    <Head title="Notes" />

    <AuthenticatedLayout>
        <template #header>
            <div class="flex items-center justify-between">
                <h2 class="text-xl font-semibold leading-tight text-gray-800">
                    My Notes
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
            <div class="mx-auto max-w-7xl space-y-6 sm:px-6 lg:px-8">
                <div
                    v-if="flash"
                    class="rounded-md bg-green-50 p-3 text-sm text-green-800"
                >
                    {{ flash }}
                </div>
                <div
                    v-if="flashError"
                    class="rounded-md bg-red-50 p-3 text-sm text-red-800"
                >
                    {{ flashError }}
                </div>

                <TextInput
                    v-model="search"
                    type="search"
                    class="block w-full"
                    placeholder="Search notes…"
                />

                <div
                    v-if="notes.data.length === 0"
                    class="rounded-lg bg-white p-10 text-center text-gray-500 shadow-sm"
                >
                    <template v-if="filters.search">
                        No notes match "{{ filters.search }}".
                    </template>
                    <template v-else>
                        <p>
                            You have no notes yet.
                            <Link
                                :href="route('notes.create')"
                                class="text-sm font-medium text-indigo-600 hover:text-indigo-800"
                            >
                                Create your first note.
                            </Link>
                        </p>
                    </template>
                </div>

                <div v-else class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                    <div
                        v-for="note in notes.data"
                        :key="note.id"
                        class="flex flex-col rounded-lg bg-white p-5 shadow-sm"
                        :class="{ 'ring-2 ring-amber-300': note.pinned }"
                    >
                        <div class="flex items-start justify-between gap-2">
                            <Link
                                :href="route('notes.edit', note.id)"
                                class="text-base font-semibold text-gray-900 hover:text-indigo-600"
                            >
                                {{ note.title }}
                            </Link>
                            <button
                                type="button"
                                class="shrink-0"
                                :class="note.pinned ? 'text-amber-500' : 'text-gray-300 hover:text-amber-400'"
                                :title="note.pinned ? 'Unpin' : 'Pin'"
                                @click="togglePin(note)"
                            >
                                <Pin class="h-4 w-4" :aria-hidden="note.pinned" />
                                <span class="sr-only">{{ note.pinned ? 'Unpin' : 'Pin' }}</span>
                            </button>
                        </div>
                        <p
                            class="mt-2 flex-1 whitespace-pre-line text-sm text-gray-600"
                        >
                            {{ excerpt(note.body) }}
                        </p>
                        <div
                            class="mt-4 flex items-center justify-between text-sm text-gray-500"
                        >
                            <span>{{ formatDate(note.updated_at) }}</span>
                            <div class="space-x-3">
                                <Link
                                    :href="route('notes.edit', note.id)"
                                    class="text-indigo-600 hover:underline"
                                    >Edit</Link
                                >
                                <button
                                    type="button"
                                    class="text-red-600 hover:underline"
                                    @click="destroy(note)"
                                >
                                    Delete
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <nav
                    v-if="notes.last_page > 1"
                    class="flex flex-wrap justify-center gap-1"
                >
                    <template v-for="link in notes.links" :key="link.label">
                        <Link
                            v-if="link.url"
                            :href="link.url"
                            preserve-scroll
                            class="rounded px-3 py-1 text-sm"
                            :class="link.active ? 'bg-indigo-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'"
                            v-html="link.label"
                        />
                        <span
                            v-else
                            class="px-3 py-1 text-sm text-gray-400"
                            v-html="link.label"
                        />
                    </template>
                </nav>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
