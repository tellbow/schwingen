<script lang="ts" setup>
import { ref } from "vue";

const items = ref([
  {
    label: "Home",
    icon: "pi pi-home",
    to: "/",
  },
  {
    label: "Association",
    to: "/association",
  },
  {
    label: "Canton",
    to: "/canton",
  },
  {
    label: "Club",
    to: "/club",
  },
  {
    label: "Wrestler",
    to: "/wrestler",
  },
  {
    label: "Places",
    to: "/places",
  },
  {
    label: "Rankings",
    to: "/rankings",
  },
  {
    label: "Account",
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
