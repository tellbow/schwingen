<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";
import { escapeFilterValue } from "~/utils/filterUtils";

// Set SEO metadata for the wrestler list page
useSeo({
  title: "Schwinger - Tellbow",
  description:
    "Durchsuchen Sie alle aktiven Schweizer Schwinger aus der ESV-Datenbank. Finden Sie Schwinger nach Name, Verein, Status und mehr.",
  keywords:
    "Schwinger, Schweizer Schwinger, ESV, Eidgenoss, Kranzer, Schwingen, Datenbank",
});

// Set structured data for the wrestler list page
const { createWebSite, createBreadcrumbList, setStructuredData } =
  useStructuredData();
const config = useRuntimeConfig();

const websiteData = createWebSite({
  name: "Tellbow - Schwinger Datenbank",
  url: `${config.public.baseUrl}/wrestler`,
  description:
    "Durchsuchen Sie alle aktiven Schweizer Schwinger aus der ESV-Datenbank. Finden Sie Schwinger nach Name, Verein, Status und mehr.",
  publisher: {
    name: "Tellbow",
    url: config.public.baseUrl,
    logo: `${config.public.baseUrl}/images/logos/tellbow_512x512.webp`,
    description: "Plattform für Schweizer Schwingen Statistiken und Analysen",
  },
});

const breadcrumbs = createBreadcrumbList([
  { name: "Home", url: config.public.baseUrl },
  { name: "Schwinger", url: `${config.public.baseUrl}/wrestler` },
]);

setStructuredData([websiteData, breadcrumbs]);

// Types
interface Wrestler {
  id: string;
  name: string;
  vorname: string;
  year: string;
  expand?: {
    club?: {
      id: string;
      name: string;
    };
    status?: {
      symbol: string;
    };
  };
}

interface StatusOption {
  name: string;
  value: string;
}

interface FilterState {
  name: { value: string; matchMode: FilterMatchMode };
  vorname: { value: string; matchMode: FilterMatchMode };
  year: { value: string; matchMode: FilterMatchMode };
  club: { value: string; matchMode: FilterMatchMode };
  status: { value: string; matchMode: FilterMatchMode };
}

interface SortState {
  field: string;
  order: string;
}

interface PageEvent {
  page: number;
}

interface SortEvent {
  sortField: string;
  sortOrder: number;
}

interface RowClickEvent {
  data: Wrestler;
}

// Composables
const pocketbase = usePocketbase();
const { layout, numberOfRows, numberOfPages } = useLayout();

// Reactive state
const loading = ref(true);
const page = ref(1);
const records = ref<Wrestler[]>([]);
const totalRecords = ref(0);

// Constants
const STATUS_OPTIONS: StatusOption[] = [
  { name: "Eidgenoss", value: " && status.symbol = '***'" },
  { name: "Teilverbands- und Bergkranzer", value: " && status.symbol = '**'" },
  {
    name: "Kantonal- und Gauverbandskranzer",
    value: " && status.symbol = '*'",
  },
  { name: "Ohne Kranz", value: " && status.symbol = ''" },
];

const filterDisplay = "row";
const sort = computed(() => layout.value !== "mobile");

// Filters and sorting
const filters = ref<FilterState>({
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  vorname: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
  club: { value: "", matchMode: FilterMatchMode.CONTAINS },
  status: {
    value: " && (status.symbol ~ '' || status.symbol = '')",
    matchMode: FilterMatchMode.EQUALS,
  },
});

const sorts = ref<SortState>({
  field: "status.symbol,name,",
  order: "-",
});

const matchModeOptionContains = ref([
  { label: "Enthält", value: FilterMatchMode.CONTAINS },
]);

// Methods
const buildSafeFilterString = (): string => {
  const filterParts = [
    `name ~ "${escapeFilterValue(filters.value.name.value)}"`,
    `vorname ~ "${escapeFilterValue(filters.value.vorname.value)}"`,
    `year ~ "${escapeFilterValue(filters.value.year.value)}"`,
    `club.name ~ "${escapeFilterValue(filters.value.club.value)}"`,
  ];

  const baseFilter = filterParts.join(" && ");
  const statusFilter = filters.value.status.value || "";

  return baseFilter + statusFilter;
};

const loadLazyData = async (): Promise<void> => {
  try {
    loading.value = true;

    const filterString = buildSafeFilterString();

    const data = await pocketbase
      .collection("wrestler")
      .getList(page.value, numberOfRows.value, {
        expand: "club,status",
        filter: filterString,
        sort: sorts.value.order + sorts.value.field + "-created",
        fields:
          "id,name,vorname,year,expand.club.id,expand.club.name,expand.status.symbol",
      });

    // Process data
    data.items.forEach((item: Wrestler) => {
      if (item.year) {
        item.year = item.year.split("-")[0];
      }
    });

    records.value = data.items;
    totalRecords.value = data.totalItems;
  } catch (error) {
    console.error("Error loading wrestler data:", error);
    // Handle error appropriately - could show user notification
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
  loadLazyData();
};

const onSort = (event: SortEvent): void => {
  sorts.value.field = event.sortField + ",";
  sorts.value.order = event.sortOrder > 0 ? "" : "-";
  loadLazyData();
};

const rowClick = async (event: RowClickEvent): Promise<void> => {
  try {
    await navigateTo(`/wrestler/${event.data.id}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

// Lifecycle
onMounted(async () => {
  await loadLazyData();
});
</script>

<template>
  <div>
    <h1 class="sr-only">Schwinger - Tellbow</h1>
    <div
      class="justify-content-center align-content-center md:flex md:flex-wrap fill-height mt-2 md:mt-5"
    >
      <!-- Desktop/Landscape Layout -->
      <DataTable
        v-if="layout === 'default'"
        v-model:filters="filters"
        class="cursor-pointer"
        :value="records"
        resizable-columns
        column-resize-mode="fit"
        show-gridlines
        table-style="md:min-width: 50rem"
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
        <template #empty>
          <div class="text-center py-4">
            <p>Keine Schwinger gefunden.</p>
          </div>
        </template>

        <template #loading>
          <div class="text-center py-4">
            <p>Schwinger werden geladen. Bitte warten.</p>
          </div>
        </template>

        <Column
          field="name"
          header="Name"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            <span>{{ data.name }}</span>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Suche"
              aria-label="Nach Namen suchen"
              @input="filterCallback()"
            />
          </template>
        </Column>

        <Column
          field="vorname"
          header="Vorname"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            <span>{{ data.vorname }}</span>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Suche"
              aria-label="Nach Vorname suchen"
              @input="filterCallback()"
            />
          </template>
        </Column>

        <Column
          field="status"
          header="Status"
          class="table-column-padding-only"
          :sortable="sort"
          :show-filter-menu="false"
          :show-clear-button="false"
        >
          <template #body="{ data }">
            <span v-if="data.expand?.status">{{
              data.expand.status.symbol
            }}</span>
            <span v-else>-</span>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Dropdown
              v-model="filterModel.value"
              :options="STATUS_OPTIONS"
              option-label="name"
              option-value="value"
              placeholder="Status wählen"
              class="p-column-filter"
              :show-clear="true"
              aria-label="Status filter"
              @change="filterCallback()"
            />
          </template>
        </Column>

        <Column
          field="year"
          header="Jahrgang"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            <span>{{ data.year }}</span>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Suche"
              aria-label="Nach Jahrgang suchen"
              @input="filterCallback()"
            />
          </template>
        </Column>

        <Column
          field="club"
          header="Schwingklub"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            <span v-if="data.expand?.club">{{ data.expand.club.name }}</span>
            <span v-else>-</span>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Suche"
              aria-label="Nach Schwingklub suchen"
              @input="filterCallback()"
            />
          </template>
        </Column>
      </DataTable>

      <!-- Mobile Layout -->
      <DataTable
        v-else
        v-model:filters="filters"
        class="cursor-pointer"
        :value="records"
        show-gridlines
        table-style="min-width: 20rem"
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
        <template #empty>
          <div class="text-center py-4">
            <p>Keine Schwinger gefunden.</p>
          </div>
        </template>

        <template #loading>
          <div class="text-center py-4">
            <p>Schwinger werden geladen. Bitte warten.</p>
          </div>
        </template>

        <Column
          field="name"
          header="Name"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            <div class="flex flex-column">
              <div class="font-bold">{{ data.name }} {{ data.vorname }}</div>
              <div class="text-sm text-gray-600">
                <span v-if="data.expand?.status">{{
                  data.expand.status.symbol
                }}</span>
                <span v-else>-</span>
              </div>
            </div>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Suche"
              aria-label="Nach Namen suchen"
              @input="filterCallback()"
            />
          </template>
        </Column>

        <Column
          field="club"
          header="Schwingklub"
          class="table-column-padding-only"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
        >
          <template #body="{ data }">
            <span v-if="data.expand?.club">{{ data.expand.club.name }}</span>
            <span v-else>-</span>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Suche"
              aria-label="Nach Schwingklub suchen"
              @input="filterCallback()"
            />
          </template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>
