import type { RouterConfig } from "@nuxt/schema";

// https://router.vuejs.org/api/interfaces/routeroptions.html
export default <RouterConfig>{
  routes: (_routes) => [
    {
      name: "home",
      path: "/home",
      component: () => import("~/pages/index.vue").then((r) => r.default || r),
    },
  ],
};
