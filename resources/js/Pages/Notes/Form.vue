<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import Checkbox from '@/Components/Checkbox.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import SecondaryButton from '@/Components/SecondaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

const props = defineProps({
    note: { type: Object, default: null },
});

const isEdit = !!props.note;

const form = useForm({
    title: props.note?.title ?? '',
    body: props.note?.body ?? '',
    pinned: props.note?.pinned ?? false,
});

const submit = () => {
    if (isEdit) {
        form.put(route('notes.update', props.note.id));
    } else {
        form.post(route('notes.store'));
    }
};
</script>

<template>
    <Head :title="isEdit ? 'Edit note' : 'New note'" />

    <AuthenticatedLayout>
        <template #header>
            <h2 class="text-xl font-semibold leading-tight text-gray-800">
                {{ isEdit ? 'Edit note' : 'New note' }}
            </h2>
        </template>

        <div class="py-8">
            <div class="mx-auto max-w-3xl sm:px-6 lg:px-8">
                <form
                    class="space-y-6 rounded-lg bg-white p-6 shadow-sm"
                    @submit.prevent="submit"
                >
                    <div>
                        <InputLabel for="title" value="Title" />
                        <TextInput
                            id="title"
                            v-model="form.title"
                            class="mt-1 block w-full"
                            required
                            autofocus
                            maxlength="255"
                        />
                        <InputError class="mt-2" :message="form.errors.title" />
                    </div>

                    <div>
                        <InputLabel for="body" value="Note" />
                        <textarea
                            id="body"
                            v-model="form.body"
                            rows="14"
                            class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                        />
                        <InputError class="mt-2" :message="form.errors.body" />
                    </div>

                    <label class="flex items-center gap-2">
                        <Checkbox v-model:checked="form.pinned" />
                        <span class="text-sm text-gray-600">Pin this note</span>
                    </label>

                    <div class="flex items-center gap-3">
                        <PrimaryButton :disabled="form.processing">
                            {{ isEdit ? 'Save changes' : 'Create note' }}
                        </PrimaryButton>
                        <Link :href="route('notes.index')">
                            <SecondaryButton>Cancel</SecondaryButton>
                        </Link>
                    </div>
                </form>
            </div>
        </div>
    </AuthenticatedLayout>
</template>
