<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);
const status = ref([
  { name: "Eidgenoss", value: "***" },
  { name: "Teilverbands- und Bergkranzer", value: "**" },
  { name: "Kantonal- und Gauverbandskranzer", value: "*" },
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
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  vorname: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
  club: { value: "", matchMode: FilterMatchMode.CONTAINS },
  status: { value: "", matchMode: FilterMatchMode.EQUALS },
});

const sorts = ref({
  field: "status.symbol,name,",
  order: "-",
});

const matchModeOptionContains = ref([
  { label: "Enthält", value: FilterMatchMode.CONTAINS },
]);

/* eslint require-await: "off" */
onMounted(async () => {
  loading.value = true;
  loadLazyData();
});

const loadLazyData = () => {
  loading.value = true;

  const statusFilterOperand = filters.value.status.value ? "=" : "~";

  pocketbase
    .collection("wrestler")
    .getList(page.value, numberOfRows.value, {
      expand: "club,status",
      filter:
        'name ~ "' +
        (filters.value.name.value || "") +
        '" && vorname ~ "' +
        (filters.value.vorname.value || "") +
        '" && year ~ "' +
        (filters.value.year.value || "") +
        '" && club.name ~ "' +
        (filters.value.club.value || "") +
        '" && status.symbol ' +
        statusFilterOperand +
        ' "' +
        (filters.value.status.value || "") +
        '"',
      sort: sorts.value.order + sorts.value.field + "-created",
      fields:
        "id,name,vorname,year,expand.club.id,expand.club.name,expand.status.symbol",
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
</script>
<template>
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
            placeholder="Suche"
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
        :show-filter-menu="false"
      >
        <template #body="{ data }">
          {{ data.vorname }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Suche"
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
          {{ data.expand.status.symbol }}
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
        :show-filter-menu="false"
      >
        <template #body="{ data }">
          {{ data.year }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Suche"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <Column
        v-if="layout === 'default'"
        field="club"
        header="Schwingklub"
        style="padding: 0.5rem"
        :sortable="sort"
        :filter-match-mode-options="matchModeOptionContains"
        :show-filter-menu="false"
      >
        <template #body="{ data }">
          {{ data.expand.club.name }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Suche"
            @input="filterCallback()"
          />
        </template>
      </Column>
    </DataTable>
  </div>
</template>
