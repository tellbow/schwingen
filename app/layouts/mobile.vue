<script lang="ts" setup>
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const appConfig = useAppConfig();
const items = ref([
  {
    label: "Start",
    to: "/",
  },
  {
    label: "Verbände",
    to: "/associations",
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
    label: "Statistiken",
    to: "/statistics",
  },
]);

function home() {
  navigateTo("/");
}

function toggleNavigation() {
  const x = document.getElementById("navigation");
  if (x !== null) {
    if (x.style.display === "block") {
      x.style.display = "none";
    } else {
      x.style.display = "block";
    }
  }
}
</script>

<template>
  <div class="layout-empty">
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"
    />
    <!-- Top Navigation Menu -->
    <div class="relative overflow-hidden bg-yellow-900 topnav">
      <div class="inline-flex bg-yellow-900">
        <img
          class="ml-1 mt-1 border-solid border-2 border-yellow-800 rounded-full"
          src="/images/logos/tellbow-192x192.png"
          style="width: 48px; height: 48px"
          alt="Tellbow"
          @click="home"
        />
        <NuxtLink to="/">Tellbow</NuxtLink>
      </div>
      <!-- Navigation links (hidden by default) -->
      <div id="navigation">
        <ul>
          <li v-for="item in items" :key="item.label">
            <NuxtLink
              :to="item.to"
              active-class="bg-yellow-950"
              @click="toggleNavigation"
              >{{ item.label }}</NuxtLink
            >
          </li>
        </ul>
      </div>
      <!-- "Hamburger menu" / "Bar icon" to toggle the navigation links -->
      <a
        href="javascript:void(0);"
        class="bg-yellow-950 icon"
        @click="toggleNavigation"
      >
        <i class="fa fa-bars" />
      </a>
    </div>
    <slot />
    <Footer />
    <ScrollTop />
  </div>
</template>

<style scoped>
/* Hide the links inside the navigation menu (except for logo/home) */
.topnav #navigation {
  display: none;
}

/* Style navigation menu links */
.topnav a {
  color: white;
  padding: 16px 16px;
  text-decoration: none;
  font-size: 17px;
  display: block;
}

/* Style the hamburger menu */
.topnav a.icon {
  display: block;
  position: absolute;
  right: 0;
  top: 0;
}

/* Style the active link (or home/logo) */
.active {
  background-color: #04aa6d;
  color: white;
}
</style>
