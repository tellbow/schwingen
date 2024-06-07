<script lang="ts" setup>
import { ref } from "vue";

const items = ref([
  {
    label: "Verbände",
    icon: "clubs-icon",
    to: "/associations",
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
    label: "Statistiken",
    icon: "statistics-icon",
    to: "/statistics",
  },
]);

function home() {
  navigateTo("/");
}
</script>

<template>
  <div class="flex bg-yellow-900">
    <img
      class="self-center mr-1 cursor-pointer hover:bg-yellow-800 border-solid border-2 border-yellow-800 rounded-full"
      src="/images/logos/tellbow_cricle_crop.png"
      style="width: 48px; height: 48px"
      alt="Tellbow"
      @click="home"
    />
    <TabMenu :model="items" />
  </div>
</template>

<style scoped>
:deep(.p-tabmenu .p-tabmenu-nav .p-tabmenuitem .p-menuitem-link:hover) {
  background-color: var(--yellow-800) !important;
}
:deep(.p-tabmenu .p-tabmenu-nav .p-tabmenuitem .p-menuitem-link) {
  background-color: var(--yellow-900);
  border: none;
}
:deep(.p-tabmenu-nav) {
  background-color: var(--yellow-900);
}
:deep(.p-menuitem-text) {
  color: #ffffff;
  font-size: 20px;
}
:deep(.p-menuitem-icon) {
  width: 20px;
  height: 20px;
  opacity: 0.5;
}
:deep(.p-menuitem-icon.bouts-icon) {
  background-image: url("/images/icons/bouts.svg");
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
:deep(.p-menuitem-icon.statistics-icon) {
  background-image: url("/images/icons/statistics.svg");
}
:deep(.p-menuitem-icon.wrestler-icon) {
  background-image: url("/images/icons/wrestler.svg");
}
</style>
