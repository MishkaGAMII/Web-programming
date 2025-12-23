<template>
  <div>
    <h2 style="margin:0 0 10px;">Quotes list</h2>
    <small class="muted">Source: https://favqs.com/api/quotes?page=…</small>

    <div v-if="error" class="alert" style="margin-top:12px;">{{ error }}</div>

    <div v-if="loading" style="margin-top:12px;">
      <small class="muted">Loading…</small>
    </div>

    <div v-else class="grid" style="margin-top:12px;">
      <QuoteCard
        v-for="q in quotes"
        :key="q.id"
        :quote="q"
        @copy="copyQuote"
      />
    </div>

    <PaginationBar
      :page="page"
      :lastPage="lastPage"
      :loading="loading"
      @go="goToPage"
    />

    <div v-if="toast" style="margin-top:10px;">
      <small class="muted">{{ toast }}</small>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useQuotes } from "../composables/useQuotes";
import QuoteCard from "../components/QuoteCard.vue";
import PaginationBar from "../components/PaginationBar.vue";

const route = useRoute();
const router = useRouter();
const { loading, error, getPage } = useQuotes();

const data = ref(null);
const toast = ref("");

const page = computed(() => {
  const n = Number(route.query.page || 1);
  return Number.isFinite(n) && n >= 1 ? Math.trunc(n) : 1;
});

const quotes = computed(() => data.value?.quotes || []);
const lastPage = computed(() => Boolean(data.value?.last_page));

async function load() {
  data.value = await getPage(page.value);
}

watch(page, load, { immediate: true }); // Watch реагує на зміну page

function goToPage(p) {
  router.push({ path: "/quotes", query: { page: String(p) } });
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
</script>

<style scoped>
.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 12px;
}
@media (min-width: 860px) {
  .grid { grid-template-columns: 1fr 1fr; }
}
</style>
