<script setup lang="ts">
// Set SEO metadata for the head2head page
useSeo({
  title: "1 vs. 1 Vergleich - Tellbow",
  description:
    "Vergleichen Sie zwei Schweizer Schwinger direkt miteinander. Head-to-Head Statistiken und Duelle zwischen Schwingern aus der ESV-Datenbank.",
  keywords:
    "Schwinger Vergleich, Head-to-Head, 1 vs 1, Schwingen Duelle, Schweizer Schwinger, ESV",
});

// Set structured data for the head2head page
const { createWebSite, createBreadcrumbList, setStructuredData } =
  useStructuredData();
const config = useRuntimeConfig();

const websiteData = createWebSite({
  name: "Tellbow - Head-to-Head Vergleich",
  url: `${config.public.baseUrl}/head2head`,
  description:
    "Vergleichen Sie zwei Schweizer Schwinger direkt miteinander. Head-to-Head Statistiken und Duelle zwischen Schwingern aus der ESV-Datenbank.",
  publisher: {
    name: "Tellbow",
    url: config.public.baseUrl,
    logo: `${config.public.baseUrl}/images/logos/tellbow_512x512.webp`,
    description: "Plattform für Schweizer Schwingen Statistiken und Analysen",
  },
});

const breadcrumbs = createBreadcrumbList([
  { name: "Home", url: config.public.baseUrl },
  { name: "1 vs. 1 Vergleich", url: `${config.public.baseUrl}/head2head` },
]);

setStructuredData([websiteData, breadcrumbs]);

// Types
interface WrestlerData {
  id: string;
  name: string;
  vorname: string;
}

// Composables
const pocketbase = usePocketbase();

// Reactive state
const messageVisible = ref(false);
const wrestlersData = ref<WrestlerData[]>([]);
const selectedWrestler = ref<string | null>(null);
const selectedOpponent = ref<string | null>(null);
const loadingWrestlers = ref(true);

// Methods
const displayWrestler = (wrestler: WrestlerData): string => {
  return `${wrestler.name} ${wrestler.vorname}`;
};

const loadWrestlers = async (): Promise<void> => {
  try {
    const customFilter = 'status != ""';
    const data = await pocketbase.collection("wrestler").getFullList(200, {
      filter: customFilter,
      sort: "-status.symbol,name,-created",
      fields: "id,name,vorname",
    });

    wrestlersData.value = data;
  } catch (error) {
    console.error("Error loading wrestlers data:", error);
    wrestlersData.value = [];
  } finally {
    loadingWrestlers.value = false;
  }
};

const navigateHead2Head = async (): Promise<void> => {
  if (!selectedWrestler.value || !selectedOpponent.value) {
    messageVisible.value = true;
    setTimeout(() => {
      messageVisible.value = false;
    }, 3500);
    return;
  }

  if (selectedWrestler.value === selectedOpponent.value) {
    messageVisible.value = true;
    setTimeout(() => {
      messageVisible.value = false;
    }, 3500);
    return;
  }

  try {
    await navigateTo(
      `/head2head/${selectedWrestler.value}-${selectedOpponent.value}`,
    );
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

// Lifecycle
onMounted(async () => {
  await loadWrestlers();
});
</script>
<template>
  <div>
    <h1 class="sr-only">Direktvergleiche - Tellbow</h1>
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title>1 vs. 1</template>
        <template #content>
          <Dropdown
            v-model="selectedWrestler"
            :options="wrestlersData"
            :option-label="displayWrestler"
            option-value="id"
            filter
            :filter-fields="['name', 'vorname']"
            :loading="loadingWrestlers"
            placeholder="Wähle einen Schwinger"
            empty-message="Keine Schwinger gefunden"
            class="m-1 w-full md:w-14rem"
          />
          <Dropdown
            v-model="selectedOpponent"
            :options="wrestlersData"
            :option-label="displayWrestler"
            option-value="id"
            filter
            :filter-fields="['name', 'vorname']"
            :loading="loadingWrestlers"
            placeholder="Wähle einen Gegner"
            empty-message="Keine Gegner gefunden"
            class="m-1 w-full md:w-14rem"
          />
          <Button
            type="button"
            label="Suchen"
            icon="pi pi-search"
            class="ml-2 mt-2 md:mt-0 bg-yellow-900 border-2 border-yellow-800"
            @click="navigateHead2Head()"
          />
          <Message v-if="messageVisible" severity="warn" :life="3000"
            >Es müssen 2 individuelle Schwinger ausgewählt werden</Message
          >
        </template>
      </Card>
    </div>
  </div>
</template>
