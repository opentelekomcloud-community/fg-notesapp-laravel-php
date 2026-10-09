<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head, Link } from '@inertiajs/vue3';

defineProps({
    users: {
        type: Object,
        required: true,
    },
});
</script>

<template>
    <AuthenticatedLayout>
        <Head title="Admin Users" />

        <template #header>
            <h2 class="text-xl font-semibold leading-tight text-gray-800">
                Users
            </h2>
        </template>

        <div class="py-12">
            <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
                <div class="overflow-hidden bg-white shadow-sm sm:rounded-lg">
                    <div class="flex flex-wrap items-baseline justify-between gap-2 border-b border-gray-200 px-6 py-4">
                        <p class="text-sm font-medium text-gray-800">
                            {{ users.total }} accounts
                        </p>
                        <p class="text-sm text-gray-500">
                            Online means active within the last 5 minutes.
                        </p>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase text-gray-500" scope="col">
                                        Name
                                    </th>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase text-gray-500" scope="col">
                                        Email
                                    </th>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase text-gray-500" scope="col">
                                        Role
                                    </th>
                                    <th class="px-6 py-3 text-left text-xs font-medium uppercase text-gray-500" scope="col">
                                        Activity
                                    </th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200 bg-white">
                                <tr v-for="user in users.data" :key="user.id">
                                    <td class="whitespace-nowrap px-6 py-4 text-sm font-medium text-gray-900">
                                        {{ user.name }}
                                    </td>
                                    <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-600">
                                        {{ user.email }}
                                    </td>
                                    <td class="whitespace-nowrap px-6 py-4 text-sm">
                                        <span
                                            v-if="user.isAdmin"
                                            class="inline-flex rounded-full bg-sky-100 px-2.5 py-0.5 text-xs font-medium text-sky-800"
                                        >
                                            Admin
                                        </span>
                                        <span v-else class="text-gray-500">User</span>
                                    </td>
                                    <td class="whitespace-nowrap px-6 py-4 text-sm">
                                        <span
                                            class="inline-flex rounded-full px-2.5 py-0.5 text-xs font-medium"
                                            :class="user.isOnline ? 'bg-emerald-100 text-emerald-800' : 'bg-gray-100 text-gray-600'"
                                        >
                                            {{ user.isOnline ? 'Online' : 'Offline' }}
                                        </span>
                                    </td>
                                </tr>
                                <tr v-if="users.data.length === 0">
                                    <td colspan="4" class="px-6 py-10 text-center text-sm text-gray-500">
                                        No user accounts found.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="flex items-center justify-between border-t border-gray-200 px-6 py-4 text-sm">
                        <span class="text-gray-600">
                            Page {{ users.current_page }} of {{ users.last_page }}
                        </span>
                        <div class="flex gap-4">
                            <Link
                                v-if="users.prev_page_url"
                                :href="users.prev_page_url"
                                class="text-gray-700 underline hover:text-gray-900"
                            >
                                Previous
                            </Link>
                            <span v-else class="text-gray-400">Previous</span>
                            <Link
                                v-if="users.next_page_url"
                                :href="users.next_page_url"
                                class="text-gray-700 underline hover:text-gray-900"
                            >
                                Next
                            </Link>
                            <span v-else class="text-gray-400">Next</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>