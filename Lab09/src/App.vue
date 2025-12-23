<template>
  <div class="container">
    <div class="card">
      <div class="nav">
        <div>
          <strong>Lab09</strong>
          <small class="muted">B09_01 — FavQs</small>
        </div>

        <div class="links">
          <RouterLink class="link" :class="{ active: $route.path === '/quotes' }" to="/quotes">Quotes</RouterLink>
          <RouterLink class="link" :class="{ active: $route.path === '/random' }" to="/random">Random</RouterLink>
        </div>
      </div>

      <div class="content">
        <RouterView />
      </div>
    </div>
  </div>
</template>

<script setup>
</script>
