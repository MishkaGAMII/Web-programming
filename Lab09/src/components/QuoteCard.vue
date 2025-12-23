<template>
  <div class="quote-card">
    <div class="body">“{{ quote.body }}”</div>
    <div class="meta">
      <small class="muted">— {{ quote.author }}</small>
      <button class="btn btn-outline" @click="$emit('copy', quote)">Copy</button>
    </div>
  </div>
</template>

<script setup>
defineProps({
  quote: { type: Object, required: true }
});

defineEmits(["copy"]);
</script>

<style scoped>
.quote-card {
  border: 1px solid #eef0f4;
  border-radius: 14px;
  padding: 14px;
  background: #fff;
}
.body { font-size: 1.05rem; line-height: 1.4; }
.meta { display: flex; justify-content: space-between; align-items: center; margin-top: 10px; gap: 10px; }
</style>
