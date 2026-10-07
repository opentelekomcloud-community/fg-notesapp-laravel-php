<script setup>
import { Eye, EyeOff } from '@lucide/vue';
import { onMounted, ref, watch } from 'vue';

defineOptions({ inheritAttrs: false });

const props = defineProps({
    type: {
        type: String,
        default: 'text',
    },
});

const model = defineModel({
    type: String,
    required: true,
});

const input = ref(null);
const passwordVisible = ref(false);

watch(model, (value) => {
    if (!value) {
        passwordVisible.value = false;
    }
});

onMounted(() => {
    if (input.value.hasAttribute('autofocus')) {
        input.value.focus();
    }
});

defineExpose({ focus: () => input.value.focus() });
</script>

<template>
    <div class="relative" :class="$attrs.class" :style="$attrs.style">
        <input
            v-bind="{ ...$attrs, class: undefined, style: undefined }"
            :type="props.type === 'password' && passwordVisible ? 'text' : props.type"
            class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            :class="{ 'pr-12': props.type === 'password' }"
            v-model="model"
            ref="input"
        />

        <button
            v-if="props.type === 'password'"
            type="button"
            class="absolute inset-y-0 right-0 flex w-11 items-center justify-center rounded-r-md text-gray-500 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500 disabled:cursor-not-allowed disabled:opacity-50"
            :aria-label="passwordVisible ? 'Hide password' : 'Show password'"
            :title="passwordVisible ? 'Hide password' : 'Show password'"
            :aria-pressed="passwordVisible"
            :aria-controls="$attrs.id"
            :disabled="$attrs.disabled !== undefined && $attrs.disabled !== false"
            @mousedown.prevent
            @click="passwordVisible = !passwordVisible"
        >
            <EyeOff v-if="passwordVisible" class="h-5 w-5" aria-hidden="true" />
            <Eye v-else class="h-5 w-5" aria-hidden="true" />
        </button>
    </div>
</template>
