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

  imports: {
    autoImport: true,
    addons: {
      vueTemplate: true,
    },
  },

  modules: ["@nuxtjs/tailwindcss", "nuxt-icon", "@nuxtjs/seo", "@nuxt/eslint"],

  security: {
    headers: {
      // ToDo: Configure contentSecurityPolicy correctly
      contentSecurityPolicy: false,
      crossOriginEmbedderPolicy:
        process.env.NODE_ENV === "development" ? "unsafe-none" : "require-corp",
    },
  },

  eslint: {
    // options here
  },

  linkChecker: {
    enabled: false,
  },

  ogImage: {
    enabled: false,
  },

  schemaOrg: {
    enabled: false,
  },

  seoExperiments: {
    enabled: false,
  },

  site: {
    url: "https://schwingen.tellbow.ch/",
    name: "Tellbow",
    description: "Alles rund ums Schwingen!",
    defaultLocale: "de",
  },

  runtimeConfig: {
    public: {
      baseUrl:
        process.env.NODE_ENV === "development"
          ? "http://localhost:8090"
          : "https://schwingen.tellbow.ch",
    },
  },

  telemetry: false,

  devtools: {
    enabled: false,
  },
});
