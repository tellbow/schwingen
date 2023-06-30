import { resolve } from "path";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  // Must be false to be used served by pocketbase
  ssr: false,

  srcDir: "app",

  css: [
    "primevue/resources/themes/saga-blue/theme.css",
    "primevue/resources/primevue.css",
    "primeicons/primeicons.css",
    "primeflex/primeflex.css",
  ],

  build: {
    transpile: ["primevue"],
  },

  hooks: {
    "pages:extend"(pages) {
      pages.push({
        name: "home",
        path: "/index.html",
        file: resolve(__dirname, "/pages/index.vue"),
      });
    },
  },

  imports: {
    autoImport: true,
    addons: {
      vueTemplate: true,
    },
  },

  modules: ["@nuxtjs/tailwindcss", "nuxt-security"],

  security: {
    headers: {
      crossOriginEmbedderPolicy:
        process.env.NODE_ENV === "development" ? "unsafe-none" : "require-corp",
    },
  },

  runtimeConfig: {
    public: {
      baseUrl: "https://schwingen.tellbow.ch",
    },
  },

  telemetry: false,

  devtools: {
    enabled: true,
  },
});
