<script lang="ts" setup>
import { ref } from "vue";

const items = ref([
  {
    label: "Verbände",
    icon: "clubs-icon",
    route: "/associations",
  },
  {
    label: "Schwinger",
    icon: "wrestler-icon",
    route: "/wrestler",
  },
  {
    label: "Schwingfeste",
    icon: "festival-icon",
    route: "/places",
  },
  {
    label: "Statistiken",
    icon: "statistics-icon",
    route: "/statistics",
  },
  {
    label: "Direktvergleich",
    icon: "bouts-icon",
    route: "/head2head",
  },
]);

function home() {
  navigateTo("/");
}
</script>

<template>
  <div class="flex bg-yellow-900">
    <img
      class="self-center ml-1 mr-1 cursor-pointer hover:bg-yellow-800 border-solid border-2 border-yellow-800 rounded-full logo-image"
      src="/images/logos/tellbow_192x192.webp"
      alt="Tellbow"
      @click="home()"
    />
    <!-- TabMenu deprecated (https://primevue.org/guides/migration/v4/) -->
    <TabMenu :model="items">
      <template #item="{ item, props }">
        <router-link
          v-if="item.route"
          v-slot="{ href, navigate }"
          :to="item.route"
          custom
        >
          <a :href="href" v-bind="props.action" @click="navigate">
            <span v-bind="props.icon" />
            <span v-bind="props.label">{{ item.label }}</span>
          </a>
        </router-link>
      </template>
    </TabMenu>
  </div>
</template>

<style scoped>
.logo-image {
  width: 48px;
  height: 48px;
}

:deep(.p-tabmenu .p-tabmenu-nav .p-tabmenuitem .p-menuitem-link:hover) {
  background-color: var(--yellow-800) !important;
  border-radius: 0px;
}
:deep(.p-tabmenu .p-tabmenu-nav .p-tabmenuitem .p-menuitem-link) {
  background-color: var(--yellow-900);
  border: none;
  transition: none;
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
