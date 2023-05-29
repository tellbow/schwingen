<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);

const filters = ref({
  result: { value: "", matchMode: FilterMatchMode.CONTAINS },
  points: { value: "", matchMode: FilterMatchMode.CONTAINS },
  fight_round: { value: "", matchMode: FilterMatchMode.CONTAINS },
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

const sorts = ref({
  field: "place.year,",
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
    .collection("bouts")
    .getList(page.value, 15, {
      expand: "wrestler,opponent,place",
      filter:
        'result ~ "' +
        (filters.value.result.value || "") +
        '" && points ~ "' +
        (filters.value.points.value || "") +
        '" && fight_round ~ "' +
        (filters.value.fight_round.value || "") +
        '" && wrestler.name ~ "' +
        (filters.value["expand.wrestler.name"].value || "") +
        '" && wrestler.vorname ~ "' +
        (filters.value["expand.wrestler.vorname"].value || "") +
        '" && opponent.name ~ "' +
        (filters.value["expand.opponent.name"].value || "") +
        '" && opponent.vorname ~ "' +
        (filters.value["expand.opponent.vorname"].value || "") +
        '" && place.name ~ "' +
        (filters.value["expand.place.name"].value || "") +
        '" && place.year ~ "' +
        (filters.value["expand.place.year"].value || "") +
        '"',
      sort: sorts.value.order + sorts.value.field + "-created",
      fields:
        "id,result,points,fight_round,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name,expand.place.year",
    })
    .then((data: { totalItems: number; items: any }) => {
      data.items.forEach((item: { expand: { place: { year: string } } }) => {
        item.expand.place.year = item.expand.place.year.split(" ")[0];
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
  sorts.value.field = event.sortField.replace("-", ".") + ",";
  sorts.value.order = event.sortOrder > 0 ? "" : "-";
  loadLazyData();
};
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
  >
    <DataTable
      v-model:filters="filters"
      class="w-11"
      :value="records"
      resizable-columns
      column-resize-mode="fit"
      show-gridlines
      table-style="min-width: 50rem"
      lazy
      paginator
      :rows="15"
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
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
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
        field="points"
        header="Punkte"
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
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
        field="fight_round"
        header="Gang"
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
      >
        <template #body="{ data }">
          {{ data.fight_round }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Filter Gang"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <Column
        field="wrestler-name"
        header="Schwinger - Name"
        filter-field="expand.wrestler.name"
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
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
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
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
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
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
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
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
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
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
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptions"
      >
        <template #body="{ data }">
          {{ data.expand.place.year }}
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
