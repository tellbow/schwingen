<script lang="ts" setup>
import { ref } from "vue";

const items = ref([
  {
    label: "Startseite",
    icon: "pi pi-home",
    to: "/",
  },
  {
    label: "Verbände & Klubs",
    to: "/clubs",
  },
  {
    label: "Schwinger",
    to: "/wrestler",
  },
  {
    label: "Schwingfeste",
    to: "/places",
  },
  {
    label: "Ranglisten",
    to: "/rankings",
  },
  {
    label: "Kämpfe",
    to: "/bouts",
  },
  {
    label: "Benutzerkonto",
    to: "/account",
  },
]);
</script>

<template>
  <div class="mt-5 ml-5 flex">
    <Avatar
      image="/images/logos/tellbow_cricle_crop.png"
      class="mr-2"
      size="large"
      shape="circle"
    />
    <TabMenu :model="items" />
  </div>
</template>
