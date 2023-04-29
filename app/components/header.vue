<script lang="ts" setup>
import { ref } from "vue";

const items = ref([
  {
    label: "Verbände & Klubs",
    icon: "clubs-icon",
    to: "/clubs",
  },
  {
    label: "Schwinger",
    icon: "wrestler-icon",
    to: "/wrestler",
  },
  {
    label: "Schwingfeste",
    icon: "festival-icon",
    to: "/places",
  },
  {
    label: "Ranglisten",
    icon: "rankings-icon",
    to: "/rankings",
  },
  {
    label: "Kämpfe",
    icon: "bouts-icon",
    to: "/bouts",
  },
  {
    label: "1 vs. 1",
    icon: "bouts-direct-icon",
    to: "/bouts-direct",
  },
  {
    label: "Benutzerkonto",
    icon: "account-icon",
    to: "/account",
  },
]);

function home() {
  navigateTo("/");
}
</script>

<template>
  <div class="mt-2 ml-2 flex">
    <img
      class="cursor-pointer hover:bg-gray-500"
      src="/images/logos/tellbow_cricle_crop.png"
      style="width: 48px; height: 48px"
      @click="home"
    />
    <TabMenu :model="items" />
  </div>
</template>

<style scoped>
/* :deep(.p-tabmenu-nav) {
  border: none;
} */
:deep(.p-menuitem-text) {
  font-size: 20px;
}
:deep(.p-menuitem-icon) {
  width: 20px;
  height: 20px;
  opacity: 0.5;
}
:deep(.p-menuitem-icon.account-icon) {
  background-image: url("/images/icons/account.svg");
}
:deep(.p-menuitem-icon.bouts-icon) {
  background-image: url("/images/icons/bouts.svg");
}
:deep(.p-menuitem-icon.bouts-direct-icon) {
  background-image: url("/images/icons/bouts-direct.svg");
}
:deep(.p-menuitem-icon.clubs-icon) {
  background-image: url("/images/icons/clubs.svg");
}
:deep(.p-menuitem-icon.festival-icon) {
  background-image: url("/images/icons/festival.svg");
}
:deep(.p-menuitem-icon.home-icon) {
  background-image: url("/images/icons/home.svg");
}
:deep(.p-menuitem-icon.rankings-icon) {
  background-image: url("/images/icons/rankings.svg");
}
:deep(.p-menuitem-icon.wrestler-icon) {
  background-image: url("/images/icons/wrestler.svg");
}
</style>
