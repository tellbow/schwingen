<script lang="ts" setup>
const { layout } = useLayout();

useHead({
  title: "Tellbow",
  meta: [
    { name: "description", content: "Alles rund ums Schwingen!" },
    {
      name: "google-site-verification",
      content: "3yA7b1xo5M3eQ_QOpOHA5sZeUe6hHItJK2M27aAdq_k",
    },
  ],
  htmlAttrs: { lang: "de" },
  link: [
    {
      rel: "icon",
      type: "image/x-icon",
      href: "/favicon.ico",
    },
  ],
});

useSeoMeta({
  title: "Tellbow",
  ogTitle: "Tellbow",
  description: "Alles rund ums Schwingen!",
  ogDescription: "Alles rund ums Schwingen!",
  ogImage: "https://schwingen.tellbow.ch/images/logos/tellbow_circle.webp",
  ogUrl: "https://schwingen.tellbow.ch/wrestler/5h1fij68r6jh8ut",
  twitterTitle: "Tellbow",
  twitterDescription: "Alles rund ums Schwingen.",
  twitterImage: "https://schwingen.tellbow.ch/images/logos/tellbow_circle.webp",
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
