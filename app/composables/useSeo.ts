export interface SeoOptions {
  title?: string;
  description?: string;
  keywords?: string;
  image?: string;
  url?: string;
  type?: "website" | "article" | "profile";
  author?: string;
  publishedTime?: string;
  modifiedTime?: string;
  section?: string;
  tags?: string[];
}

export const useSeo = (options: SeoOptions = {}) => {
  const config = useRuntimeConfig();
  const route = useRoute();

  // Default values
  const defaults = {
    title: "Tellbow - Alles rund ums Schwingen",
    description:
      "Umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern aus der ESV-Datenbank.",
    keywords:
      "Schwingen, Schweizer Schwinger, ESV, Eidgenössischer Schwingerverband, Schwingfeste, Ranglisten, Statistiken",
    image: `${config.public.baseUrl}/images/logos/tellbow_512x512.png`,
    type: "website" as const,
    url: `${config.public.baseUrl}${route.path}`,
  };

  // Merge options with defaults
  const seoData = {
    ...defaults,
    ...options,
  };

  // Set the page title
  useHead({
    title: seoData.title,
    meta: [
      // Basic meta tags
      { name: "description", content: seoData.description },
      { name: "keywords", content: seoData.keywords },
      { name: "author", content: seoData.author || "Tellbow" },

      // Open Graph tags
      { property: "og:title", content: seoData.title },
      { property: "og:description", content: seoData.description },
      { property: "og:image", content: seoData.image },
      { property: "og:url", content: seoData.url },
      { property: "og:type", content: seoData.type },
      { property: "og:site_name", content: "Tellbow" },
      { property: "og:locale", content: "de_CH" },

      // Twitter Card tags
      { name: "twitter:card", content: "summary_large_image" },
      { name: "twitter:title", content: seoData.title },
      { name: "twitter:description", content: seoData.description },
      { name: "twitter:image", content: seoData.image },

      // Additional meta tags
      { name: "robots", content: "index, follow" },
      { name: "language", content: "de" },
      { name: "revisit-after", content: "7 days" },
    ],
    link: [
      // Canonical URL
      { rel: "canonical", href: seoData.url },
    ],
  });

  return {
    seoData,
  };
};
