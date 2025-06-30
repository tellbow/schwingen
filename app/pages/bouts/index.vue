<script setup lang="ts">
// Set SEO metadata for the bouts page
import { FilterMatchMode } from "primevue/api";
import { escapeFilterValue } from "~/utils/filterUtils";

useSeo({
  title: `Paarungen - Tellbow`,
  description: `Alle Paarungen und Ergebnisse von Schweizer Schwingern aus den Jahren 2015-2025. Detaillierte Resultate, Punkte und Gang.`,
  keywords: `Kanton, Gauverband, Schwinger, Schweizer Schwinger, ESV, Schwingen`,
});

// Types
interface BoutData {
  id: string;
  result: string;
  points: string;
  fight_round: string;
  expand: {
    wrestler: {
      id: string;
      name: string;
      vorname: string;
    };
    opponent: {
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

interface FilterState {
  result: { value: string; matchMode: FilterMatchMode };
  points: { value: string; matchMode: FilterMatchMode };
  fight_round: { value: string; matchMode: FilterMatchMode };
  "expand.wrestler.name": { value: string; matchMode: FilterMatchMode };
  "expand.wrestler.vorname": { value: string; matchMode: FilterMatchMode };
  "expand.opponent.name": { value: string; matchMode: FilterMatchMode };
  "expand.opponent.vorname": { value: string; matchMode: FilterMatchMode };
  "expand.place.name": { value: string; matchMode: FilterMatchMode };
  "expand.place.year": { value: string; matchMode: FilterMatchMode };
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

// Composables
const pocketbase = usePocketbase();
const { numberOfRows, numberOfPages } = useLayout();

// Reactive state
const loading = ref(true);
const page = ref(1);
const records = ref<BoutData[]>([]);
const totalRecords = ref(0);

// Filter options
const result = ref(["o", "-", "+"]);
const points = ref([
  "0.25",
  "8.25",
  "8.50",
  "8.75",
  "9.00",
  "9.25",
  "9.50",
  "9.75",
  "10.00",
  "10.25",
]);
const fightRound = ref(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]);
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
  result: { value: "", matchMode: FilterMatchMode.EQUALS },
  points: { value: "", matchMode: FilterMatchMode.EQUALS },
  fight_round: { value: "", matchMode: FilterMatchMode.EQUALS },
  "expand.wrestler.name": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
  },
  "expand.wrestler.vorname": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
  },
  "expand.opponent.name": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
  },
  "expand.opponent.vorname": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
  },
  "expand.place.name": { value: "", matchMode: FilterMatchMode.CONTAINS },
  "expand.place.year": { value: "", matchMode: FilterMatchMode.CONTAINS },
});

const sorts = ref<SortState>({
  field: "place.year,",
  order: "-",
});

const matchModeOptionContains = ref([
  { label: "Enthält", value: FilterMatchMode.CONTAINS },
]);

// Methods
const buildSafeFilterString = (): string => {
  const filterParts = [
    `result ~ "${escapeFilterValue(filters.value.result.value)}"`,
    `points ~ "${escapeFilterValue(filters.value.points.value)}"`,
    `fight_round ~ "${escapeFilterValue(filters.value.fight_round.value)}"`,
    `wrestler.name ~ "${escapeFilterValue(filters.value["expand.wrestler.name"].value)}"`,
    `wrestler.vorname ~ "${escapeFilterValue(filters.value["expand.wrestler.vorname"].value)}"`,
    `opponent.name ~ "${escapeFilterValue(filters.value["expand.opponent.name"].value)}"`,
    `opponent.vorname ~ "${escapeFilterValue(filters.value["expand.opponent.vorname"].value)}"`,
    `place.name ~ "${escapeFilterValue(filters.value["expand.place.name"].value)}"`,
    `place.year >= "2015"`,
    `place.year ~ "${escapeFilterValue(filters.value["expand.place.year"].value)}"`,
  ];

  return filterParts.join(" && ");
};

const loadLazyData = async (): Promise<void> => {
  try {
    loading.value = true;

    const filterString = buildSafeFilterString();

    const data = await pocketbase
      .collection("bouts")
      .getList(page.value, numberOfRows.value, {
        expand: "wrestler,opponent,place",
        filter: filterString,
        sort: sorts.value.order + sorts.value.field + "-created",
        fields:
          "id,result,points,fight_round,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name,expand.place.year",
      });

    // Process data
    data.items.forEach((item: BoutData) => {
      if (item.expand.place.year) {
        item.expand.place.year = item.expand.place.year.split(" ")[0];
      }
    });

    records.value = data.items;
    totalRecords.value = data.totalItems;
  } catch (error) {
    console.error("Error loading bouts data:", error);
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
  loadLazyData();
};

const onSort = (event: SortEvent): void => {
  sorts.value.field = event.sortField.replace("-", ".") + ",";
  sorts.value.order = event.sortOrder > 0 ? "" : "-";
  loadLazyData();
};

// Lifecycle
onMounted(async () => {
  await loadLazyData();
});
</script>
<template>
  <div>
    <h1 class="sr-only">Gänge - Tellbow</h1>
    <div
      class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
    >
      <DataTable
        v-model:filters="filters"
        class="w-11 table-style-default"
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
      >
        <template #empty> Keine Kämpfe gefunden. </template>
        <template #loading> Kämpfe werden geladen. Bitte warten. </template>
        <Column
          field="result"
          header="Resultat"
          class="table-column-small"
          sortable
          :show-filter-menu="false"
          :show-clear-button="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.result }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Dropdown
              v-model="filterModel.value"
              :options="result"
              placeholder="Filter Resultat"
              class="p-column-filter"
              :show-clear="true"
              @change="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="points"
          header="Punkte"
          class="table-column-small"
          sortable
          :show-filter-menu="false"
          :show-clear-button="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.points }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Dropdown
              v-model="filterModel.value"
              :options="points"
              placeholder="Filter Punkte"
              class="p-column-filter"
              :show-clear="true"
              @change="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="fight_round"
          header="Gang"
          class="table-column-small"
          sortable
          :show-filter-menu="false"
          :show-clear-button="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.fight_round }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Dropdown
              v-model="filterModel.value"
              :options="fightRound"
              placeholder="Filter Gang"
              class="p-column-filter"
              :show-clear="true"
              @change="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="wrestler-name"
          header="Schwinger - Name"
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
          field="wrestler-vorname"
          header="Schwinger - Vorname"
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
          field="opponent-name"
          header="Gegner - Name"
          filter-field="expand.opponent.name"
          class="table-column-large"
          sortable
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.expand.opponent.name }}
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
          field="opponent-vorname"
          header="Gegner - Vorname"
          filter-field="expand.opponent.vorname"
          class="table-column-large"
          sortable
          :filter-match-mode-options="matchModeOptionContains"
          :show-filter-menu="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.expand.opponent.vorname }}
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
          field="place-name"
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
          field="place-year"
          header="Jahr"
          filter-field="expand.place.year"
          class="table-column-medium"
          sortable
          :show-filter-menu="false"
          :show-clear-button="false"
          :pt="{
            filterInput: { class: 'w-fit' },
          }"
        >
          <template #body="{ data }">
            {{ data.expand.place.year }}
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
      </DataTable>
    </div>
  </div>
</template>
