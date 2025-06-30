import process from "node:process";

const sw = process.env.SW === "true";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  ...(process.env.NODE_ENV !== "development" && {
    app: {
      head: {
        meta: [
          {
            name: "google-site-verification",
            content: "3yA7b1xo5M3eQ_QOpOHA5sZeUe6hHItJK2M27aAdq_k",
          },
        ],
        link: [
          {
            rel: "apple-touch-icon",
            href: "/images/logos/tellbow_192x192.webp",
            sizes: "192x192",
          },
        ],
        script: [
          ...(process.env.NODE_ENV !== "development"
            ? [
                {
                  src: "https://www.googletagmanager.com/gtag/js?id=G-XT9Y2TP58B",
                  async: true,
                },
                {
                  innerHTML: `
                window.dataLayer = window.dataLayer || [];
                function gtag(){dataLayer.push(arguments);}
                gtag('js', new Date());
                gtag('config', 'G-XT9Y2TP58B');
              `,
                  type: "text/javascript",
                },
              ]
            : []),
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

  vite: {
    build: {
      rollupOptions: {
        output: {
          manualChunks: {
            vendor: ["vue", "vue-router"],
          },
        },
      },
    },
    css: {
      devSourcemap: false,
    },
  },

  imports: {
    autoImport: true,
    addons: {
      vueTemplate: true,
    },
  },

  modules: [
    "@nuxtjs/tailwindcss",
    "@nuxt/icon",
    "@nuxtjs/seo",
    "@nuxt/eslint",
    "@vite-pwa/nuxt",
    "@nuxtjs/fontaine",
    "@nuxt/devtools",
    "nuxt-security",
    "nuxt-primevue",
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

  site: {
    url: "https://schwingen.tellbow.ch/",
    name: "Tellbow",
    description:
      "Alles rund ums Schwingen! Umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern aus der ESV-Datenbank.",
    defaultLocale: "de",
    indexable: true,
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
    routeRules: {
      // Cache static assets aggressively
      "/images/**": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable", // 1 year
        },
      },
      "/_nuxt/**": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable", // 1 year for build assets
        },
      },
      "/assets/**": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable", // 1 year
        },
      },
      // Cache CSS and JS files
      "**/*.css": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable",
        },
      },
      "**/*.js": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable",
        },
      },
      // Cache webp images
      "**/*.webp": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable",
        },
      },
      // Cache other image formats
      "**/*.{png,jpg,jpeg,svg,ico}": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable",
        },
      },
      // Cache fonts
      "**/*.{woff,woff2,ttf,eot}": {
        headers: {
          "cache-control": "public, max-age=31536000, immutable",
        },
      },
      // HTML pages - shorter cache for dynamic content
      "/**": {
        headers: {
          "cache-control": "public, max-age=3600, must-revalidate", // 1 hour
        },
      },
    },
  },

  primevue: {
    components: {
      include: [
        "Accordion",
        "AccordionTab",
        "Badge",
        "Button",
        "Column",
        "Card",
        "DataView",
        "DataTable",
        "Dropdown",
        "InputText",
        "Message",
        "OverlayPanel",
        "ProgressSpinner",
        "ScrollTop",
        "TabMenu",
      ],
    },
    options: {
      locale: {
        apply: "Anwenden",
        clear: "Löschen",
        contains: "Enthält",
        equals: "Gleich",
        noFilter: "Kein Filter",
        fileSizeTypes: [],
        dayNames: [],
        dayNamesShort: [],
        dayNamesMin: [],
        monthNames: [],
        monthNamesShort: [],
      },
      ripple: true,
    },
  },

  experimental: {
    payloadExtraction: false,
  },

  pwa: {
    strategies: sw ? "injectManifest" : "generateSW",
    srcDir: sw ? "service-worker" : undefined,
    filename: sw ? "sw.ts" : undefined,
    registerType: "autoUpdate",
    manifest: {
      name: "Tellbow - Alles rund ums Schwingen",
      short_name: "Tellbow",
      description:
        "Umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern",
      theme_color: "#ffffff",
      background_color: "#ffffff",
      display: "standalone",
      orientation: "portrait-primary",
      scope: "/",
      start_url: "/",
      lang: "de",
      categories: ["sports", "entertainment"],
      icons: [
        {
          src: "images/logos/tellbow_192x192.webp",
          sizes: "192x192",
          type: "image/webp",
        },
        {
          src: "images/logos/tellbow_512x512.webp",
          sizes: "512x512",
          type: "image/webp",
        },
        {
          src: "images/logos/tellbow_512x512.webp",
          sizes: "512x512",
          type: "image/webp",
          purpose: "any maskable",
        },
      ],
    },
    workbox: {
      globPatterns: ["**/*.{js,css,html,png,svg,ico,webp,woff,woff2}"],
      runtimeCaching: [
        // Cache images with network-first strategy
        {
          urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp|ico)$/,
          handler: "CacheFirst",
          options: {
            cacheName: "images-cache",
            expiration: {
              maxEntries: 100,
              maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
            },
            cacheableResponse: {
              statuses: [0, 200],
            },
          },
        },
        // Cache CSS and JS files with stale-while-revalidate
        {
          urlPattern: /\.(?:css|js)$/,
          handler: "StaleWhileRevalidate",
          options: {
            cacheName: "static-resources",
            expiration: {
              maxEntries: 50,
              maxAgeSeconds: 60 * 24 * 60 * 60, // 60 days
            },
            cacheableResponse: {
              statuses: [0, 200],
            },
          },
        },
        // Cache fonts with cache-first strategy
        {
          urlPattern: /\.(?:woff|woff2|ttf|eot)$/,
          handler: "CacheFirst",
          options: {
            cacheName: "fonts-cache",
            expiration: {
              maxEntries: 20,
              maxAgeSeconds: 60 * 24 * 60 * 60, // 60 days
            },
            cacheableResponse: {
              statuses: [0, 200],
            },
          },
        },
        // Cache API responses with network-first strategy
        {
          urlPattern: /^https:\/\/.*\/api\/.*/,
          handler: "NetworkFirst",
          options: {
            cacheName: "api-cache",
            expiration: {
              maxEntries: 100,
              maxAgeSeconds: 5 * 60, // 5 minutes
            },
            networkTimeoutSeconds: 3,
            cacheableResponse: {
              statuses: [0, 200],
            },
          },
        },
      ],
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
