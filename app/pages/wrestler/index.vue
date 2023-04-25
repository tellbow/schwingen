<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);

const filters = ref({
  name: { value: "", matchMode: FilterMatchMode.CONTAINS },
  vorname: { value: "", matchMode: FilterMatchMode.CONTAINS },
  year: { value: "", matchMode: FilterMatchMode.CONTAINS },
  category: { value: "", matchMode: FilterMatchMode.CONTAINS },
});

const matchModeOptions = ref([
  { label: "Contains", value: FilterMatchMode.CONTAINS },
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
    .getList(page.value, 10, {
      filter:
        'name ~ "' +
        (filters.value.name.value || "") +
        '" && vorname ~ "' +
        (filters.value.vorname.value || "") +
        '" && year ~ "' +
        (filters.value.year.value || "") +
        '" && category ~ "' +
        (filters.value.category.value || "") +
        '"',
      sort: "name,-created",
    })
    .then((data) => {
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

async function rowClick(event: any) {
  await navigateTo("/wrestler/" + event.data.id);
}
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
  >
    <DataTable
      v-model:filters="filters"
      :value="records"
      lazy
      paginator
      :rows="10"
      data-key="id"
      filter-display="row"
      :row-hover="true"
      :total-records="totalRecords"
      :loading="loading"
      @page="onPage($event)"
      @filter="onFilter()"
      @row-click="rowClick($event)"
    >
      <template #empty> Keine Schwinger gefunden. </template>
      <template #loading>
        Schwingerdatenbank wird geladen. Bitte warten.
      </template>
      <Column
        field="name"
        header="Name"
        style="min-width: 12rem"
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
        style="min-width: 12rem"
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
        style="min-width: 12rem"
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
        field="category"
        header="Kategorie"
        style="min-width: 12rem"
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
