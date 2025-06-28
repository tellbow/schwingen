<script setup lang="ts">
// Set SEO metadata for the home page
useSeo({
  title: "Tellbow - Alles rund ums Schwingen",
  description:
    "Entdecken Sie umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern. Verbände, Schwingfeste und detaillierte Analysen aus der ESV-Datenbank.",
  keywords:
    "Schwingen, Schweizer Schwinger, ESV, Eidgenössischer Schwingerverband, Schwingfeste, Ranglisten, Statistiken, Verbände",
});

// Set structured data for the home page
const { createWebSite, createBreadcrumbList, setStructuredData } =
  useStructuredData();

const config = useRuntimeConfig();

const websiteData = createWebSite({
  name: "Tellbow",
  url: config.public.baseUrl,
  description:
    "Alles rund ums Schwingen! Umfassende Statistiken, Ranglisten und Profile von Schweizer Schwingern aus der ESV-Datenbank.",
  publisher: {
    name: "Tellbow",
    url: config.public.baseUrl,
    logo: `${config.public.baseUrl}/images/logos/tellbow_512x512.webp`,
    description: "Plattform für Schweizer Schwingen Statistiken und Analysen",
  },
});

const breadcrumbs = createBreadcrumbList([
  { name: "Home", url: config.public.baseUrl },
]);

setStructuredData([websiteData, breadcrumbs]);
</script>

<template>
  <div>
    <h1 class="sr-only">Tellbow - Alles rund ums Schwingen</h1>
    <div
      class="justify-center flex md:align-items-center align-items-stretch flex-wrap"
    >
      <Card
        class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Verbände </template>
        <template #content>
          <p>Informationen zu den Teilverbänden und dessen Unterverbänden.</p>
          <Button
            label="Anzeigen"
            class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
            @click="navigateTo('/associations')"
          />
        </template>
      </Card>
      <Card
        class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Schwinger </template>
        <template #content>
          <p>
            Enthält alle aktiven Schwinger aus der
            <a href="https://esv.ch/hkesv/datenbank/">Datenbank des ESV</a
            >(Stand 19.06.2025).
          </p>
          <Button
            label="Anzeigen"
            class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
            @click="navigateTo('/wrestler')"
          />
        </template>
      </Card>
      <Card
        class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Schwingfeste </template>
        <template #content>
          <p>
            Enthält alle Schwingfeste der Aktiven aus den Jahren 2015 - 2025.
          </p>
          <Button
            label="Anzeigen"
            class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
            @click="navigateTo('/places')"
          />
        </template>
      </Card>
      <Card
        class="w-screen md:w-5 ml-2 md:ml-4 mt-2 mr-2 md:mr-4"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Statistiken </template>
        <template #content>
          <p>Statistiken über Schwinger</p>
          <Button
            label="Anzeigen"
            class="w-half mt-3 bg-yellow-900 border-2 border-yellow-800"
            @click="navigateTo('/statistics')"
          />
        </template>
      </Card>
    </div>
  </div>
</template>
