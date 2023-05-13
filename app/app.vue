<script lang="ts" setup>
const ready = true;

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  )
    ? "mobile"
    : "default";
</script>

<template>
  <div>
    <Toast />
    <Toast position="bottom-right" group="br" />
    <NuxtLayout v-show="ready" :name="layout">
      <NuxtLoadingIndicator />
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>
