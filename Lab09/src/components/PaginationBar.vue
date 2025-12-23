<template>
  <div class="pager">
    <button class="btn btn-outline" :disabled="page <= 1 || loading" @click="$emit('go', page - 1)">Prev</button>

    <div class="row" style="align-items:center;">
      <small class="muted">Page</small>
      <input
        ref="pageInput"
        style="width:90px;"
        type="number"
        min="1"
        v-model="local"
        @keydown.enter="apply"
      />
      <button class="btn btn-primary" :disabled="loading" @click="apply">Go</button>
    </div>

    <button class="btn btn-outline" :disabled="lastPage || loading" @click="$emit('go', page + 1)">Next</button>
  </div>
</template>

<script setup>
import { computed, ref, watch, nextTick } from "vue";

const props = defineProps({
  page: { type: Number, required: true },
  lastPage: { type: Boolean, default: false },
  loading: { type: Boolean, default: false }
});
const emit = defineEmits(["go"]);

const local = ref(String(props.page));
const pageInput = ref(null);

watch(
  () => props.page,
  async (p) => {
    local.value = String(p);
    await nextTick();
    pageInput.value?.focus(); // ref використання для DOM-фокусу
  }
);

const parsed = computed(() => {
  const n = Number(local.value);
  return Number.isFinite(n) && n >= 1 ? Math.trunc(n) : 1;
});

function apply() {
  emit("go", parsed.value);
}
</script>

<style scoped>
.pager {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-top: 1px solid #eef0f4;
  flex-wrap: wrap;
}
</style>
