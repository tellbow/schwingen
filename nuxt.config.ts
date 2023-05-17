// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  app: {
    head: {
      title: "Tellbow",
    },
  },
  ssr: false, // Must be false to be used served by pocketbase
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
  imports: {
    autoImport: true,
    addons: {
      vueTemplate: true,
    },
  },
  modules: ["@nuxtjs/tailwindcss"],
  runtimeConfig: {
    public: {
      baseUrl: "https://schwingen.tellbow.ch",
    },
  },
  telemetry: false,
});
