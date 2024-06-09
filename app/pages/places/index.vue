<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);
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

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";

const filterDisplay = "row";
const sort = layout !== "mobile";

const filters = ref({
  number: { value: "", matchMode: FilterMatchMode.CONTAINS },
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  location: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
  type: { value: "", matchMode: FilterMatchMode.EQUALS },
});

const sorts = ref({
  field: "year,",
  order: "-",
});

const matchModeOptions = ref([
  { label: "Enthält", value: FilterMatchMode.CONTAINS },
]);

/* eslint require-await: "off" */
onMounted(async () => {
  loading.value = true;
  loadLazyData();
});

const loadLazyData = () => {
  loading.value = true;

  pocketbase
    .collection("places")
    .getList(page.value, numberOfRows.value, {
      expand: "placeType",
      filter:
        'number ~ "' +
        (filters.value.number.value || "") +
        '" && name ~ "' +
        (filters.value.name.value || "") +
        '" && location ~ "' +
        (filters.value.location.value || "") +
        '" && year >= "2015' +
        '" && year ~ "' +
        (filters.value.year.value || "") +
        '" && placeType.type ~ "' +
        (filters.value.type.value || "") +
        '"',
      sort: sorts.value.order + sorts.value.field + "-created",
      fields: "id,number,name,location,year,expand.placeType.type",
    })
    .then((data) => {
      data.items.forEach((item) => {
        item.year = item.year.split(" ")[0];
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
  await navigateTo("/rankings/" + event.data.id);
}

const numberOfRows = computed(() => {
  if (layout === "mobile") {
    return 10;
  } else {
    return 15;
  }
});

const numberOfPages = computed(() => {
  if (layout === "mobile") {
    return 3;
  } else {
    return 4;
  }
});

function displayYear(year: string) {
  if (layout === "mobile") {
    return year.split("-")[0];
  } else {
    return year;
  }
}
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-2 md:mt-5"
  >
    <DataTable
      v-model:filters="filters"
      class="w-11 md:w-9 cursor-pointer"
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
      <template #empty> Keine Schwingfeste gefunden. </template>
      <template #loading> Schwingfeste werden geladen. Bitte warten. </template>
      <Column
        v-if="layout === 'default'"
        field="number"
        header="Nummer"
        style="padding: 0.5rem"
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
        style="padding: 0.5rem"
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
        v-if="layout === 'default'"
        field="location"
        header="Ort"
        style="padding: 0.5rem"
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
        style="padding: 0.5rem"
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
        v-if="layout === 'default'"
        field="type"
        header="Typ"
        style="padding: 0.5rem"
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
  </div>
</template>
