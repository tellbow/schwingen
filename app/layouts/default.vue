<script lang="ts" setup>
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const appConfig = useAppConfig();

// Set default SEO metadata for all pages
useSeo();
</script>
<template>
  <div class="layout-empty">
    <Header />
    <slot />
    <Footer />
    <ScrollTop />
  </div>
</template>
