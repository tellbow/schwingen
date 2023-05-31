<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  )
    ? "mobile"
    : "default";

const filterDisplay: any = layout === "mobile" ? "menu" : "row";
const sort = layout !== "mobile";

const filters = ref({
  number: { value: "", matchMode: FilterMatchMode.CONTAINS },
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  location: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
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
    .getList(page.value, 15, {
      filter:
        'number ~ "' +
        (filters.value.number.value || "") +
        '" && name ~ "' +
        (filters.value.name.value || "") +
        '" && location ~ "' +
        (filters.value.location.value || "") +
        '" && year ~ "' +
        (filters.value.year.value || "") +
        '"',
      sort: sorts.value.order + sorts.value.field + "-created",
      fields: "id,number,name,location,year",
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
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-2 md:mt-5"
  >
    <DataTable
      v-model:filters="filters"
      class="w-11 md:w-7 cursor-pointer"
      :value="records"
      resizable-columns
      column-resize-mode="fit"
      show-gridlines
      table-style="md:min-width: 50rem"
      :page-link-size="4"
      lazy
      paginator
      :rows="15"
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
        :filter-match-mode-options="matchModeOptions"
      >
        <template #body="{ data }">
          {{ data.year }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Filter Jahr"
            @input="filterCallback()"
          />
        </template>
      </Column>
    </DataTable>
  </div>
</template>
