<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const route = useRoute();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";

const filterDisplay: any = layout === "mobile" ? "menu" : "row";
const sort = layout !== "mobile";

const filters = ref({
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  vorname: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
  category: { value: "", matchMode: FilterMatchMode.CONTAINS },
});

const sorts = ref({
  field: "name,",
  order: "",
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
    .collection("wrestler")
    .getList(page.value, 15, {
      filter:
        'name ~ "' +
        (filters.value.name.value || "") +
        '" && vorname ~ "' +
        (filters.value.vorname.value || "") +
        '" && year ~ "' +
        (filters.value.year.value || "") +
        '" && category ~ "' +
        (filters.value.category.value || "") +
        '" && club.id ~ "' +
        route.params.id +
        '"',
      sort: sorts.value.order + sorts.value.field + "-created",
      fields: "id,name,vorname,year,category",
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
      <template #empty> Keine Schwinger gefunden. </template>
      <template #loading> Schwinger werden geladen. Bitte warten. </template>
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
        field="vorname"
        header="Vorname"
        style="padding: 0.5rem"
        :sortable="sort"
        :filter-match-mode-options="matchModeOptions"
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
        field="year"
        header="Jahrgang"
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
            placeholder="Filter Jahrgang"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <Column
        v-if="layout === 'default'"
        field="category"
        header="Kategorie"
        style="padding: 0.5rem"
        :sortable="sort"
        :filter-match-mode-options="matchModeOptions"
      >
        <template #body="{ data }">
          {{ data.category }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Filter Kategorie"
            @input="filterCallback()"
          />
        </template>
      </Column>
    </DataTable>
  </div>
</template>
