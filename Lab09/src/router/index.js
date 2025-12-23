import { createRouter, createWebHistory } from "vue-router";
import QuotesList from "../views/QuotesList.vue";
import RandomQuote from "../views/RandomQuote.vue";

export default createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", redirect: "/quotes" },
    { path: "/quotes", component: QuotesList },
    { path: "/random", component: RandomQuote }
  ]
});
