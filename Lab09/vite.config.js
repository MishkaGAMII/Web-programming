import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: {
      // щоб не впертись у CORS: запити йдуть на /favqs/* і проксіються на favqs.com/api/*
      "/favqs": {
        target: "https://favqs.com/api",
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/favqs/, "")
      }
    }
  }
});
