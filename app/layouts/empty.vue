<script lang="ts" setup>
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const appConfig = useAppConfig();
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
  <div>
    <slot />
  </div>
</template>
