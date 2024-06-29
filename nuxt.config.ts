import process from "node:process";

const sw = process.env.SW === "true";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ...(process.env.NODE_ENV !== "development" && {
    app: {
      head: {
        meta: [
          {
            "name": "google-site-verification",
            "content": "3yA7b1xo5M3eQ_QOpOHA5sZeUe6hHItJK2M27aAdq_k",
          },
        ],
        script: [
          {
            src: "https://stats.mcathome.ch/script.js",
            "data-website-id": "ace4da01-246d-4efd-bccf-3d39ee00c864",
          },
        ],
      },
    },
  }),

  // Must be false to be used served by pocketbase
  ssr: false,

  srcDir: "app",

  css: ["~/assets/css/default.css"],

  tailwindcss: {
    cssPath: false,
  },

  build: {
    transpile: ["primevue"],
  },

  imports: {
    autoImport: true,
    addons: {
      vueTemplate: true,
    },
  },

  modules: [
    "@nuxtjs/tailwindcss",
    "nuxt-icon",
    "@nuxtjs/seo",
    "@nuxt/eslint",
    "@vite-pwa/nuxt",
    "@nuxtjs/fontaine",
    "@nuxt/devtools",
    "nuxt-security",
  ],

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

  nitro: {
    compressPublicAssets: true,
  },

  pwa: {
    strategies: sw ? "injectManifest" : "generateSW",
    srcDir: sw ? "service-worker" : undefined,
    filename: sw ? "sw.ts" : undefined,
    registerType: "autoUpdate",
    manifest: {
      name: "Nuxt Vite PWA",
      short_name: "NuxtVitePWA",
      theme_color: "#ffffff",
      icons: [
        {
          src: "images/logos/tellbow-192x192.png",
          sizes: "192x192",
          type: "image/png",
        },
        {
          src: "images/logos/tellbow-512x512.png",
          sizes: "512x512",
          type: "image/png",
        },
        {
          src: "images/logos/tellbow-512x512.png",
          sizes: "512x512",
          type: "image/png",
          purpose: "any maskable",
        },
      ],
    },
    workbox: {
      globPatterns: ["**/*.{js,css,html,png,svg,ico}"],
    },
    injectManifest: {
      globPatterns: ["**/*.{js,css,html,png,svg,ico}"],
    },
    client: {
      installPrompt: true,
      // you don't need to include this: only for testing purposes
      // if enabling periodic sync for update use 1 hour or so (periodicSyncForUpdates: 3600)
      periodicSyncForUpdates: 20,
    },
    devOptions: {
      enabled: true,
      suppressWarnings: false,
      navigateFallback: "/",
      navigateFallbackAllowlist: [/^\/$/],
      type: "module",
    },
  },
});
