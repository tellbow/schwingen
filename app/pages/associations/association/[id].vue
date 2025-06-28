<script setup lang="ts">
// Set SEO metadata for association detail pages
import { FilterMatchMode } from "primevue/api";

useSeo({
  title: `Schwingerverband - Tellbow`,
  description: `Alle Schwinger des jeweiligen Verbands. Durchsuchen Sie aktive Schwinger nach Name, Status und Jahrgang.`,
  keywords: `Schwingerverband, Schwinger, Schweizer Schwinger, ESV, Schwingen`,
});

// Set structured data for the association detail page
const { createSportsOrganization, createBreadcrumbList, setStructuredData } =
  useStructuredData();
const config = useRuntimeConfig();

const pocketbase = usePocketbase();
const route = useRoute();
const { layout, numberOfRows, numberOfPages } = useLayout();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);
const status = ref([
  { name: "Eidgenoss", value: " && status.symbol = '***'" },
  { name: "Teilverbands- und Bergkranzer", value: " && status.symbol = '**'" },
  {
    name: "Kantonal- und Gauverbandskranzer",
    value: " && status.symbol = '*'",
  },
  { name: "Ohne Kranz", value: " && status.symbol = ''" },
]);

const filterDisplay = "row";
const sort = layout !== "mobile";

const filters = ref({
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  vorname: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
  status: {
    value: " && (status.symbol ~ '' || status.symbol = '')",
    matchMode: FilterMatchMode.EQUALS,
  },
});

const sorts = ref({
  field: "status.symbol,name,",
  order: "-",
});

const matchModeOptionContains = ref([
  { label: "Enthält", value: FilterMatchMode.CONTAINS },
]);

const associationId = route.params.id as string;

const organizationData = createSportsOrganization({
  name: `Teilverband`,
  url: `${config.public.baseUrl}/associations/association/${associationId}`,
  description: `Teilverband für Schweizer Schwingen`,
});

const breadcrumbs = createBreadcrumbList([
  { name: "Home", url: config.public.baseUrl },
  { name: "Verbände", url: `${config.public.baseUrl}/associations` },
  {
    name: `Teilverband`,
    url: `${config.public.baseUrl}/associations/association/${associationId}`,
  },
]);

setStructuredData([organizationData, breadcrumbs]);

/* eslint require-await: "off" */
onMounted(async () => {
  loading.value = true;
  loadLazyData();
});

const loadLazyData = () => {
  loading.value = true;

  pocketbase
    .collection("wrestler")
    .getList(page.value, numberOfRows.value, {
      expand: "status",
      filter:
        'name ~ "' +
        (filters.value.name.value || "") +
        '" && vorname ~ "' +
        (filters.value.vorname.value || "") +
        '" && year ~ "' +
        (filters.value.year.value || "") +
        '"' +
        (filters.value.status.value || "") +
        ' && club.canton.association ~ "' +
        route.params.id +
        '"',
      sort: sorts.value.order + sorts.value.field + "-created",
      fields: "id,name,vorname,year,expand.status.symbol",
    })
    .then((data) => {
      data.items.forEach((item) => {
        item.year = item.year.split("-")[0];
      });
      records.value = data.items;
      totalRecords.value = data.totalItems;
      loading.value = false;
    });
};

const onPage = (event: { page: number }) => {
  page.value = event.page + 1;
  loadLazyData();
};

const onFilter = () => {
  loadLazyData();
};

const onSort = (event: { sortField: string; sortOrder: number }) => {
  sorts.value.field = event.sortField + ",";
  sorts.value.order = event.sortOrder > 0 ? "" : "-";
  loadLazyData();
};

async function rowClick(event: any) {
  await navigateTo("/wrestler/" + event.data.id);
}
</script>
<template>
  <div>
    <h1 class="sr-only">Teilverband Detail</h1>
    <div
      class="justify-content-center align-content-center md:flex md:flex-wrap fill-height mt-2 md:mt-5"
    >
      <DataTable
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
        <template #empty> Keine Schwinger gefunden. </template>
        <template #loading> Schwinger werden geladen. Bitte warten. </template>
        <Column
          field="name"
          header="Name"
          style="padding: 0.5rem"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
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
          field="vorname"
          header="Vorname"
          style="padding: 0.5rem"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
        >
          <template #body="{ data }">
            {{ data.vorname }}
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
          v-if="layout === 'default'"
          field="status"
          header="Status"
          style="padding: 0.5rem"
          :sortable="sort"
          :show-filter-menu="false"
          :show-clear-button="false"
        >
          <template #body="{ data }">
            <p v-if="data.expand.status">{{ data.expand.status.symbol }}</p>
            <p v-else>-</p>
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <Dropdown
              v-model="filterModel.value"
              :options="status"
              option-label="name"
              option-value="value"
              placeholder="Suche"
              class="p-column-filter"
              :show-clear="true"
              @change="filterCallback()"
            />
          </template>
        </Column>
        <Column
          field="year"
          header="Jahrgang"
          style="padding: 0.5rem"
          :sortable="sort"
          :filter-match-mode-options="matchModeOptionContains"
        >
          <template #body="{ data }">
            {{ data.year }}
          </template>
          <template #filter="{ filterModel, filterCallback }">
            <InputText
              v-model="filterModel.value"
              type="text"
              class="p-column-filter"
              placeholder="Filter Jahrgang"
              @input="filterCallback()"
            />
          </template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>
