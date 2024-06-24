<script lang="ts" setup>
const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";

useHead({
  title: "Tellbow",
  meta: [{ name: "description", content: "Alles rund ums Schwingen!" }],
  htmlAttrs: { lang: "de" },
  link: [
    {
      rel: "icon",
      type: "image/png",
      href: "/favicon.png",
    },
  ],
});

useSeoMeta({
  title: "Tellbow",
  ogTitle: "Tellbow",
  description: "Alles rund ums Schwingen!",
  ogDescription: "Alles rund ums Schwingen!",
  ogImage: "https://schwingen.tellbow.ch/images/logos/tellbow_circle.png",
  ogUrl: "https://schwingen.tellbow.ch/wrestler/5h1fij68r6jh8ut",
  twitterTitle: "Tellbow",
  twitterDescription: "Alles rund ums Schwingen.",
  twitterImage: "https://schwingen.tellbow.ch/images/logos/tellbow_circle.png",
  twitterCard: "summary",
});
</script>

<template>
  <div>
    <NuxtPwaManifest />
    <NuxtLayout :name="layout">
      <NuxtLoadingIndicator />
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>
