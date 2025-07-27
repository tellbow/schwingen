<script setup lang="ts">
// Set SEO metadata for the rankings page
import { FilterMatchMode } from "primevue/api";
import { escapeFilterValue } from "~/utils/filterUtils";

useSeo({
  title: "Ranglisten - Tellbow",
  description:
    "Alle Ranglisten und Ergebnisse von Schweizer Schwingern aus den Jahren 2015-2025. Detaillierte Resultate, Punkte und Kränze.",
  keywords:
    "Ranglisten, Schwingen Ergebnisse, Schweizer Schwinger, ESV, Punkte, Kränze, Schwingfeste",
});

// Set structured data for the rankings list page
const { createWebSite, createBreadcrumbList, setStructuredData } =
  useStructuredData();
const config = useRuntimeConfig();

const websiteData = createWebSite({
  name: "Tellbow - Ranglisten",
  url: `${config.public.baseUrl}/rankings`,
  description:
    "Alle Ranglisten und Ergebnisse von Schweizer Schwingern aus den Jahren 2015-2025. Detaillierte Resultate, Punkte und Kränze.",
  publisher: {
    name: "Tellbow",
    url: config.public.baseUrl,
    logo: `${config.public.baseUrl}/images/logos/tellbow_512x512.webp`,
    description: "Plattform für Schweizer Schwingen Statistiken und Analysen",
  },
});

const breadcrumbs = createBreadcrumbList([
  { name: "Home", url: config.public.baseUrl },
  { name: "Ranglisten", url: `${config.public.baseUrl}/rankings` },
]);

setStructuredData([websiteData, breadcrumbs]);

// Types
interface RankingData {
  id: string;
  rank: string;
  rank2: string;
  points: string;
  final: boolean;
  result: string;
  wreath: boolean;
  status: string;
  year?: string;
  bouts?: BoutData[];
  expand: {
    wrestler: {
      id: string;
      name: string;
      vorname: string;
    };
    place: {
      id: string;
      name: string;
      year: string;
    };
  };
}

interface BoutData {
  id: string;
  result: string;
  points: string;
  fight_round: string;
  expand: {
    opponent: {
      id: string;
      name: string;
      vorname: string;
    };
  };
}

interface FilterState {
  rank: { value: string; matchMode: string; prefix: string };
  points: { value: string; matchMode: string; prefix: string };
  final: { value: string; matchMode: string; prefix: string };
  result: { value: string; matchMode: string; prefix: string };
  wreath: { value: string; matchMode: string; prefix: string };
  status: { value: string; matchMode: string; prefix: string };
  "expand.wrestler.name": {
    value: string;
    matchMode: string;
    prefix: string;
  };
  "expand.wrestler.vorname": {
    value: string;
    matchMode: string;
    prefix: string;
  };
  "expand.place.name": {
    value: string;
    matchMode: string;
    prefix: string;
  };
  "expand.place.year": {
    value: string;
    matchMode: string;
    prefix: string;
  };
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

interface RowExpandEvent {
  data: RankingData;
}

interface RowCollapseEvent {
  data: {
    id: string;
  };
}

// Composables
const pocketbase = usePocketbase();
const { layout, numberOfRows, numberOfPages } = useLayout();

// Reactive state
const loading = ref(true);
const page = ref(1);
const records = ref<RankingData[]>([]);
const totalRecords = ref(0);
const expandedRows = ref();

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

// Filters and sorting
const filters = ref<FilterState>({
  rank: { value: "", matchMode: FilterMatchMode.EQUALS, prefix: 'rank = "' },
  points: {
    value: "",
    matchMode: FilterMatchMode.EQUALS,
    prefix: 'points = "',
  },
  final: {
    value: "",
    matchMode: FilterMatchMode.EQUALS,
    prefix: "final = ",
  },
  result: {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'result ~ "',
  },
  wreath: {
    value: "",
    matchMode: FilterMatchMode.EQUALS,
    prefix: "wreath = ",
  },
  status: {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'status ~ "',
  },
  "expand.wrestler.name": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'wrestler.name ~ "',
  },
  "expand.wrestler.vorname": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'wrestler.vorname ~ "',
  },
  "expand.place.name": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'place.name ~ "',
  },
  "expand.place.year": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'place.year >= "2015" && place.year ~ "',
  },
});

const sorts = ref<SortState>({
  field: "place.year,",
  order: "-",
});

const matchModeOptionEquals = ref([
  { label: "Gleich", value: FilterMatchMode.EQUALS },
]);
const matchModeOptionContains = ref([
  { label: "Enthält", value: FilterMatchMode.CONTAINS },
]);

// Methods
const buildSafeFilterString = (): string => {
  return Object.values(filters.value)
    .map((filter) => {
      const { value, prefix } = filter;
      if (value && value !== "") {
        const escapedValue = escapeFilterValue(value);
        if (!prefix.includes('"')) {
          return prefix + escapedValue;
        }
        return prefix + escapedValue + '"';
      }
      return "";
    })
    .filter(Boolean)
    .join(" && ");
};

const loadLazyData = async (): Promise<void> => {
  try {
    loading.value = true;

    const filterString = buildSafeFilterString();

    const data = await pocketbase
      .collection("rankings")
      .getList(page.value, numberOfRows.value, {
        expand: "wrestler,place",
        filter: filterString,
        sort: sorts.value.order + sorts.value.field + "-created",
        fields:
          "id,rank,rank2,points,final,result,wreath,status,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.place.id,expand.place.name,expand.place.year",
      });

    records.value = data.items.map((item: any) => ({
      ...item,
      year: item.expand.place.year.split(" ")[0],
      bouts: [],
    })) as unknown as RankingData[];
    totalRecords.value = data.totalItems;
  } catch (error) {
    console.error("Error loading rankings data:", error);
    records.value = [];
    totalRecords.value = 0;
  } finally {
    loading.value = false;
  }
};

const loadLazySubData = async (
  wrestlerId: string,
  placeId: string,
): Promise<void> => {
  try {
    loading.value = true;

    const data = await pocketbase.collection("bouts").getList(page.value, 10, {
      expand: "opponent",
      filter: `wrestler.id = '${escapeFilterValue(wrestlerId)}' && place.id = '${escapeFilterValue(placeId)}'`,
      sort: "fight_round,-created",
      fields:
        "id,result,points,fight_round,expand.opponent.id,expand.opponent.name,expand.opponent.vorname",
    });

    records.value.forEach((item: RankingData) => {
      if (
        item.expand.wrestler.id === wrestlerId &&
        item.expand.place.id === placeId
      ) {
        item.bouts = data.items as unknown as BoutData[];
      }
    });
  } catch (error) {
    console.error("Error loading sub data:", error);
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
    sorts.value.field = event.sortField.replace("_", ".") + ",";
  }
  sorts.value.order = (event.sortOrder ?? 0) > 0 ? "" : "-";
  loadLazyData();
};

const onRowExpand = (event: RowExpandEvent): void => {
  const { wrestler, place } = event.data.expand;
  loadLazySubData(wrestler.id, place.id);
};

const onRowCollapse = (event: RowCollapseEvent): void => {
  const objIndex = records.value.findIndex(
    (obj: RankingData) => obj.id === event.data.id,
  );
  if (objIndex !== -1) {
    records.value[objIndex].bouts = [];
  }
};

// Lifecycle
onMounted(async () => {
  await loadLazyData();
});
</script>
<template>
  <div>
    <h1 class="sr-only">Ranglisten - Tellbow</h1>
    <div
      class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
    >
      <DataTable
        v-model:filters="filters"
        v-model:expanded-rows="expandedRows"
        class="w-11 cursor-pointer table-style-default"
        :value="records"
        resizable-columns
        column-resize-mode="fit"
        show-gridlines
        :page-link-size="numberOfPages"
        lazy
        paginator
        :rows="numberOfRows"
        data-key="id"
        filter-display="row"
        :row-hover="true"
        :total-records="totalRecords"
        :loading="loading"
        @page="onPage($event)"
        @filter="onFilter()"
        @sort="onSort($event)"
        @row-expand="onRowExpand($event)"
        @row-collapse="onRowCollapse($event)"
      >
        <template #empty> Keine Ranglisten gefunden. </template>
        <template #loading> Ranglisten werden geladen. Bitte warten. </template>
        <Column expander class="table-column-expander" />
        <Column
          field="rank"
          header="Rang"
          class="table-column-small"
          :filter-match-mode-options="matchModeOptionEquals"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.rank }}{{ data.rank2 }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Rang"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="points"
          header="Punkte"
          class="table-column-small"
          :filter-match-mode-options="matchModeOptionEquals"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.points }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Punkte"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          v-if="layout === 'default'"
          field="final"
          header="Schlussgang"
          class="table-column-small"
          :filter-match-mode-options="matchModeOptionEquals"
          :show-filter-menu="false"
          :show-clear-button="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            <Icon v-if="data.final" name="gis:flag-finish" />
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Checkbox
              v-model="filterModel.value"
              :binary="true"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="result"
          header="Resultat"
          class="table-column-small"
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.result }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Resultat"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          v-if="layout === 'default'"
          field="wreath"
          header="Kranz"
          class="table-column-small"
          :filter-match-mode-options="matchModeOptionEquals"
          :show-filter-menu="false"
          :show-clear-button="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            <Icon v-if="data.wreath" name="mingcute:wreath-fill" />
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Checkbox
              v-model="filterModel.value"
              :binary="true"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          v-if="layout === 'default'"
          field="status"
          header="Status"
          class="table-column-small"
          :filter-match-mode-options="matchModeOptionEquals"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.status }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Status"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="wrestler_name"
          header="Name"
          filter-field="expand.wrestler.name"
          class="table-column-large"
          sortable
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.expand.wrestler.name }}
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
          field="wrestler_vorname"
          header="Vorname"
          filter-field="expand.wrestler.vorname"
          class="table-column-large"
          sortable
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.expand.wrestler.vorname }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Vorname"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="place_name"
          header="Schwingfest"
          filter-field="expand.place.name"
          class="table-column-large"
          sortable
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.expand.place.name }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Schwingfest"
              @input="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="place_year"
          header="Jahr"
          filter-field="expand.place.year"
          class="table-column-small"
          sortable
          :show-filter-menu="false"
          :show-clear-button="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.year }}
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
        <template #expansion="data">
          <div class="p-1">
            <DataTable :value="data.data.bouts">
              <Column field="result" header="Resultat" />
              <Column field="points" header="Punkte" sortable />
              <Column field="fight_round" header="Gang" sortable />
              <Column
                field="expand.opponent.name"
                header="Gegner - Name"
                sortable
              />
              <Column
                field="expand.opponent.vorname"
                header="Gegner - Vorname"
                sortable
              />
            </DataTable>
          </div>
        </template>
      </DataTable>
    </div>
  </div>
</template>
