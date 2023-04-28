<script lang="ts" setup>
// Ensures that the pocketbase url is set to the current host
const pb = usePocketbase();
onMounted(() => {
  const url = window.location.host;
  if (!url.includes("localhost")) {
    pb.baseUrl = "https://" + url;
  }
});
</script>

<template>
  <div class="layout-empty">
    <Header />
    <slot />
    <Footer />
    <ScrollTop />
  </div>
</template>
