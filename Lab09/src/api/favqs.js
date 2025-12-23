const BASE = "/favqs";
const TOKEN = import.meta.env.VITE_FAVQS_TOKEN;

function headers() {
  if (!TOKEN) throw new Error("VITE_FAVQS_TOKEN is not set");
  return { Authorization: `Token token=${TOKEN}` };
}

async function getJson(url) {
  const res = await fetch(url, { headers: headers() });
  if (!res.ok) {
    const txt = await res.text().catch(() => "");
    throw new Error(`HTTP ${res.status}: ${txt || res.statusText}`);
  }
  return res.json();
}

export function fetchQuotesPage(page = 1) {
  return getJson(`${BASE}/quotes?page=${encodeURIComponent(page)}`);
}

export function fetchQotd() {
  return getJson(`${BASE}/qotd`);
}
