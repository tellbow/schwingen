<script lang="ts" setup>
const ready = true;

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  )
    ? "mobile"
    : "default";

useHead({
  title: "Tellbow",
  meta: [{ name: "description", content: "Alles rund ums Schwingen." }],
  htmlAttrs: { lang: "de" },
});

useSeoMeta({
  title: "Tellbow",
  ogTitle: "Tellbow",
  description: "Alles rund ums Schwingen.",
  ogDescription: "Alles rund ums Schwingen.",
  ogImage: "https://schwingen.tellbow.ch/images/logos/tellbow.svg",
});
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
