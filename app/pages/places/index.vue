<script setup lang="ts">
// Set SEO metadata for the places page
import { FilterMatchMode } from "primevue/api";
import { escapeFilterValue } from "~/utils/filterUtils";

useSeo({
  title: "Schwingfeste - Tellbow",
  description:
    "Alle Schwingfeste der Aktiven aus den Jahren 2015-2025. Eidgenössische, Teilverbands-, Kantonale und regionale Schwingfeste.",
  keywords:
    "Schwingfeste, Eidgenössisches Schwingfest, Teilverbandsschwingfest, Kantonales Schwingfest, Bergschwingfest, Schweizer Schwingen",
});

// Set structured data for the places page
const { createWebSite, createBreadcrumbList, setStructuredData } =
  useStructuredData();
const config = useRuntimeConfig();

const websiteData = createWebSite({
  name: "Tellbow - Schwingfeste",
  url: `${config.public.baseUrl}/places`,
  description:
    "Alle Schwingfeste der Aktiven aus den Jahren 2015-2025. Eidgenössische, Teilverbands-, Kantonale und regionale Schwingfeste.",
  publisher: {
    name: "Tellbow",
    url: config.public.baseUrl,
    logo: `${config.public.baseUrl}/images/logos/tellbow_512x512.webp`,
    description: "Plattform für Schweizer Schwingen Statistiken und Analysen",
  },
});

const breadcrumbs = createBreadcrumbList([
  { name: "Home", url: config.public.baseUrl },
  { name: "Schwingfeste", url: `${config.public.baseUrl}/places` },
]);

setStructuredData([websiteData, breadcrumbs]);

// Types
interface PlaceData {
  id: string;
  number: string;
  name: string;
  location: string;
  year: string;
  expand: {
    placeType: {
      type: string;
    };
  };
}

interface FilterState {
  number: { value: string; matchMode: string };
  name: { value: string; matchMode: string };
  location: { value: string; matchMode: string };
  year: { value: string; matchMode: string };
  type: { value: string; matchMode: string };
}

interface SortState {
  field: string;
  order: string;
}

interface PageEvent {
  page: number;
}

interface SortEvent {
  sortField: string | ((item: any) => string) | undefined;
  sortOrder: number | null | undefined;
}

interface RowClickEvent {
  data: PlaceData;
}

// Composables
const pocketbase = usePocketbase();
const { layout, numberOfRows, numberOfPages } = useLayout();

// Reactive state
const loading = ref(true);
const page = ref(1);
const records = ref<PlaceData[]>([]);
const totalRecords = ref(0);

// Debounced filter function
let filterTimeout: NodeJS.Timeout | null = null;
const debouncedLoadData = () => {
  if (filterTimeout) {
    clearTimeout(filterTimeout);
  }
  filterTimeout = setTimeout(() => {
    loadLazyData();
  }, 300);
};

// Filter options
const year = ref([
  "2015",
  "2016",
  "2017",
  "2018",
  "2019",
  "2020",
  "2021",
  "2022",
  "2023",
  "2024",
  "2025",
]);
const placeType = ref([
  "Sonstige",
  "Gauverband",
  "Regional",
  "mit eidgenössischem Charakter",
  "Eidgenössisch",
  "Teilverband",
  "Kantonal",
  "Berg",
]);

const filterDisplay = "row";
const sort = computed(() => layout.value !== "mobile");

// Filters and sorting
const filters = ref<FilterState>({
  number: { value: "", matchMode: FilterMatchMode.CONTAINS },
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  location: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
  type: { value: "", matchMode: FilterMatchMode.EQUALS },
});

const sorts = ref<SortState>({
  field: "year,",
  order: "-",
});

const matchModeOptions = ref([
  { label: "Enthält", value: FilterMatchMode.CONTAINS },
]);

// Methods
const buildSafeFilterString = (): string => {
  const filterParts: string[] = [];

  // Only add number filter if it has a value
  if (filters.value.number.value) {
    filterParts.push(
      `number ~ "${escapeFilterValue(filters.value.number.value)}"`,
    );
  }

  // Handle mobile layout differently - search across name, location, and year
  if (layout.value === "mobile") {
    const searchValue = escapeFilterValue(filters.value.name.value);
    if (searchValue) {
      filterParts.push(
        `(name ~ "${searchValue}" || location ~ "${searchValue}" || year ~ "${searchValue}")`,
      );
    }
  } else {
    // Desktop layout - separate filters for each field
    if (filters.value.name.value) {
      filterParts.push(
        `name ~ "${escapeFilterValue(filters.value.name.value)}"`,
      );
    }
    if (filters.value.location.value) {
      filterParts.push(
        `location ~ "${escapeFilterValue(filters.value.location.value)}"`,
      );
    }
  }

  // Always add year constraint
  filterParts.push(`year >= "2015"`);

  // Only add year filter if it has a value
  if (filters.value.year.value) {
    filterParts.push(`year ~ "${escapeFilterValue(filters.value.year.value)}"`);
  }

  // Only add type filter if it has a value
  if (filters.value.type.value) {
    filterParts.push(
      `placeType.type ~ "${escapeFilterValue(filters.value.type.value)}"`,
    );
  }

  return filterParts.join(" && ");
};

const loadLazyData = async (): Promise<void> => {
  try {
    loading.value = true;

    const filterString = buildSafeFilterString();

    const data = await pocketbase
      .collection("places")
      .getList(page.value, numberOfRows.value, {
        expand: "placeType",
        filter: filterString,
        sort: sorts.value.order + sorts.value.field + "-created",
        fields: "id,number,name,location,year,expand.placeType.type",
      });

    // Process data efficiently
    const processedItems = data.items.map((item: any) => ({
      ...item,
      year: item.year ? item.year.split(" ")[0] : item.year,
    }));

    records.value = processedItems as unknown as PlaceData[];
    totalRecords.value = data.totalItems;
  } catch (error) {
    console.error("Error loading places data:", error);
    records.value = [];
    totalRecords.value = 0;
  } finally {
    loading.value = false;
  }
};

const onPage = (event: PageEvent): void => {
  page.value = event.page + 1;
  loadLazyData();
};

const onFilter = (): void => {
  page.value = 1; // Reset to first page when filtering
  debouncedLoadData();
};

const onSort = (event: SortEvent): void => {
  if (typeof event.sortField === "string") {
    sorts.value.field = event.sortField + ",";
  }
  sorts.value.order = (event.sortOrder ?? 0) > 0 ? "" : "-";
  loadLazyData();
};

const rowClick = async (event: RowClickEvent): Promise<void> => {
  try {
    await navigateTo(`/rankings/${event.data.id}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

const displayYear = (year: string): string => {
  if (!year) return "";
  if (layout.value === "mobile") {
    return year.split("-")[0];
  } else {
    return year;
  }
};

// Lifecycle
onMounted(async () => {
  await loadLazyData();
});
</script>
<template>
  <div>
    <h1 class="sr-only">Schwingfeste - Tellbow</h1>
    <div
      class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-2 md:mt-5"
    >
      <!-- Desktop/Landscape Layout -->
      <DataTable
        v-if="layout === 'default'"
        v-model:filters="filters"
        class="w-11 md:w-9 cursor-pointer table-style-responsive"
        :value="records"
        resizable-columns
        column-resize-mode="fit"
        show-gridlines
        :page-link-size="numberOfPages"
        lazy
        paginator
        :rows="numberOfRows"
        data-key="id"
        :filter-display="filterDisplay"
        :row-hover="true"
        :total-records="totalRecords"
        :loading="loading"
        @page="onPage($event)"
        @filter="onFilter()"
        @sort="onSort($event)"
        @row-click="rowClick($event)"
      >
        <template #empty> Keine Schwingfeste gefunden. </template>
        <template #loading>
          Schwingfeste werden geladen. Bitte warten.
        </template>
        <Column
          field="number"
          header="Nummer"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptions"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            {{ data.number }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Nummer"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="name"
          header="Name"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptions"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            {{ data.name }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Name"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="location"
          header="Ort"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptions"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            {{ data.location }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Ort"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="year"
          header="Jahr"
          class="table-column-padding-only"
          :sortable="sort"
          :show-filter-menu="false"
          :show-clear-button="false"
        >
          <template #body="{ data }">
            <p>{{ displayYear(data.year) }}</p>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Dropdown
              v-model="filterModel.value"
              :options="year"
              placeholder="Filter Jahr"
              class="p-column-filter"
              :show-clear="true"
              @change="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="type"
          header="Typ"
          class="table-column-padding-only"
          :sortable="sort"
          :show-filter-menu="false"
          :show-clear-button="false"
        >
          <template #body="{ data }">
            {{ data.expand.placeType.type }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Dropdown
              v-model="filterModel.value"
              :options="placeType"
              placeholder="Filter Typ"
              class="p-column-filter"
              :show-clear="true"
              @change="filterCallback()"
            />
          </template>
        </Column>
      </DataTable>

      <!-- Mobile Layout -->
      <DataTable
        v-else
        v-model:filters="filters"
        class="w-11 md:w-9 cursor-pointer table-style-compact"
        :value="records"
        show-gridlines
        :page-link-size="numberOfPages"
        lazy
        paginator
        :rows="numberOfRows"
        data-key="id"
        :filter-display="filterDisplay"
        :row-hover="true"
        :total-records="totalRecords"
        :loading="loading"
        @page="onPage($event)"
        @filter="onFilter()"
        @sort="onSort($event)"
        @row-click="rowClick($event)"
      >
        <template #empty> Keine Schwingfeste gefunden. </template>
        <template #loading>
          Schwingfeste werden geladen. Bitte warten.
        </template>
        <Column
          field="name"
          header="Schwingfest"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptions"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            <div class="flex flex-column">
              <div class="font-bold">{{ data.name }}</div>
              <div class="text-sm text-gray-600">
                {{ data.location }}, {{ displayYear(data.year) }}
              </div>
            </div>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Suche nach Name, Ort oder Jahr"
              @input="filterCallback()"
            />
          </template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>
