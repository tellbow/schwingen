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
    .collection("bouts")
    .getList(page.value, 10, {
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
      sort: "-place.year,place.name,-created",
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
    >
      <template #empty> Keine Kämpfe gefunden. </template>
      <template #loading> Kämpfe werden geladen. Bitte warten. </template>
      <Column
        field="result"
        header="Schwingerstatus"
        style="min-width: 12rem"
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
            placeholder="Filter Schwingerstatus"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <Column
        field="points"
        header="Punkte"
        style="min-width: 12rem"
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
        style="min-width: 12rem"
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
        field="wrestler_name"
        header="Schwinger - Name"
        filter-field="expand.wrestler.name"
        style="min-width: 12rem"
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
        field="wrestler_vorname"
        header="Schwinger - Vorname"
        filter-field="expand.wrestler.vorname"
        style="min-width: 12rem"
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
        field="opponent_name"
        header="Gegner - Name"
        filter-field="expand.opponent.name"
        style="min-width: 12rem"
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
        field="opponent_vorname"
        header="Gegner - Vorname"
        filter-field="expand.opponent.vorname"
        style="min-width: 12rem"
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
        field="place_name"
        header="Schwingfest"
        filter-field="expand.place.name"
        style="min-width: 12rem"
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
        field="place_year"
        header="Jahr"
        filter-field="expand.place.year"
        style="min-width: 12rem"
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
