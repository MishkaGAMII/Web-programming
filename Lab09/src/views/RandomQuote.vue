<template>
  <div>
    <h2 style="margin:0 0 10px;">Random quote (QOTD)</h2>
    <small class="muted">Source: https://favqs.com/api/qotd</small>

    <div class="row" style="margin:12px 0;">
      <button class="btn btn-primary" :disabled="loading" @click="load">Random quote</button>
    </div>

    <div v-if="error" class="alert">{{ error }}</div>

    <div v-if="loading">
      <small class="muted">Loading…</small>
    </div>

    <div v-else-if="quote">
      <QuoteCard :quote="quote" @copy="copyQuote" />
      <div v-if="toast" style="margin-top:10px;">
        <small class="muted">{{ toast }}</small>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useQuotes } from "../composables/useQuotes";
import QuoteCard from "../components/QuoteCard.vue";

const { loading, error, getQotd } = useQuotes();

const quote = ref(null);
const toast = ref("");

async function load() {
  const res = await getQotd();
  quote.value = res?.quote || null;
}

async function copyQuote(q) {
  try {
    await navigator.clipboard.writeText(`"${q.body}" — ${q.author}`);
    toast.value = "Copied to clipboard";
    setTimeout(() => (toast.value = ""), 1200);
  } catch {
    toast.value = "Copy failed";
    setTimeout(() => (toast.value = ""), 1200);
  }
}

onMounted(load);
</script>
