import { ref } from "vue";
import { fetchQuotesPage, fetchQotd } from "../api/favqs";

export function useQuotes() {
  const loading = ref(false);
  const error = ref("");

  async function run(fn) {
    loading.value = true;
    error.value = "";
    try {
      return await fn();
    } catch (e) {
      error.value = e?.message || "Request failed";
      return null;
    } finally {
      loading.value = false;
    }
  }

  const getPage = (page) => run(() => fetchQuotesPage(page));
  const getQotd = () => run(() => fetchQotd());

  return { loading, error, getPage, getQotd };
}
