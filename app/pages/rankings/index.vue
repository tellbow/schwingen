<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

const selectedPlaces = ref();
const places = ref();
const placeSelectionDisabled = ref(true);

const selectedYears = ref();
const years = ref([
  { year: "1998" },
  { year: "2000" },
  { year: "2001" },
  { year: "2002" },
  { year: "2003" },
  { year: "2004" },
  { year: "2005" },
  { year: "2006" },
  { year: "2007" },
  { year: "2008" },
  { year: "2009" },
  { year: "2010" },
  { year: "2011" },
  { year: "2012" },
  { year: "2013" },
  { year: "2014" },
  { year: "2015" },
  { year: "2016" },
  { year: "2017" },
  { year: "2018" },
  { year: "2019" },
  { year: "2020" },
  { year: "2021" },
  { year: "2022" },
  { year: "2023" },
]);

/* eslint require-await: "off" */
onMounted(async () => {
  const dataTable = document.getElementById("dataTable");
  if (dataTable) {
    dataTable.style.display = "none";
  }
});

const filters = ref({
  global: { value: null, matchMode: FilterMatchMode.CONTAINS },
  rank: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
  points: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
  result: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
  "expand.wrestler.name": {
    value: null,
    matchMode: FilterMatchMode.STARTS_WITH,
  },
  "expand.wrestler.vorname": {
    value: null,
    matchMode: FilterMatchMode.STARTS_WITH,
  },
  "expand.place.name": { value: null, matchMode: FilterMatchMode.STARTS_WITH },
  "expand.place.year": { value: null, matchMode: FilterMatchMode.STARTS_WITH },
});

function loadData() {
  onPlaceChange();
  const dataTable = document.getElementById("dataTable");
  if (dataTable) {
    dataTable.style.display = "block";
  }
}

async function onYearChange() {
  placeSelectionDisabled.value = false;
  const filterParts = [];
  for (let index = 0; index < selectedYears.value.length; index++) {
    const element = selectedYears.value[index];
    filterParts.push('year ~ "' + element.year + '"');
  }
  const joinedFilter = filterParts.join(" || ");
  await pocketbase
    .collection("places")
    .getFullList(200 /* batch size */, {
      sort: "-created",
      filter: joinedFilter,
    })
    .then((data) => {
      const picked = data.map((item) => {
        return {
          id: item.id,
          name: item.name + " " + item.location + " " + item.year.split("-")[0],
        };
      });
      places.value = picked;
    });
}

// ToDo: Doesn't work, why?
async function onSelectAllYearChange() {
  await pocketbase
    .collection("places")
    .getFullList(200 /* batch size */, {
      sort: "-created",
    })
    .then((data) => {
      const picked = data.map((item) => {
        return {
          id: item.id,
          name: item.name + " " + item.location + " " + item.year.split("-")[0],
        };
      });
      places.value = picked;
    });
}

async function onPlaceChange() {
  const filterParts = [];
  for (let index = 0; index < selectedPlaces.value.length; index++) {
    const element = selectedPlaces.value[index];
    filterParts.push('place.id = "' + element + '"');
  }
  const joinedFilter = filterParts.join(" || ");
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      sort: "-created",
      filter: joinedFilter,
      expand: "wrestler,place",
    })
    .then((data) => {
      records.value = data;
      loading.value = false;
    });
}

// ToDo: Doesn't work, why?
// async function onSelectAllPlaceChange() {
//     await pocketbase.collection('rankings').getFullList(200 /* batch size */, {
//         sort: '-created',
//         expand: 'wrestler,place',
//     }).then((data) => {
//         records.value = data;
//         loading.value = false;
//     });
// }
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
  >
    <div
      class="justify-content-center align-content-center display: flex flex-wrap fill-height mb-2"
    >
      <p class="pt-2 pr-2">Jahr(e):</p>
      <MultiSelect
        v-model="selectedYears"
        display="chip"
        :options="years"
        filter
        option-label="year"
        placeholder="Wähle Jahr(e)"
        :max-selected-labels="3"
        class="w-full md:w-20rem"
        @selectall-change="onSelectAllYearChange()"
        @change="onYearChange()"
      />
      <p class="pt-2 pl-10 pr-2">Schwingfest(e):</p>
      <MultiSelect
        v-model="selectedPlaces"
        display="chip"
        :options="places"
        filter
        option-label="name"
        option-value="id"
        placeholder="Wähle Schwingest(e)"
        :max-selected-labels="3"
        :disabled="placeSelectionDisabled"
        :virtual-scroller-options="{ itemSize: 44 }"
        class="w-full md:w-20rem"
      />
      <!-- <MultiSelect v-model="selectedPlaces" display="chip" :options="places" filter optionLabel="name" optionValue="id" placeholder="Wähle Schwingest(e)"
        :maxSelectedLabels="3" :disabled="placeSelectionDisabled" :virtualScrollerOptions="{ itemSize: 44 }" @selectall-change="onSelectAllPlaceChange()" @change="onPlaceChange()" class="w-full md:w-20rem" /> -->
      <!-- ToDo: When filter is empty, don't load anything on click -->
      <Button label="Filtern" class="ml-4" @click="loadData" />
    </div>
    <div id="dataTable">
      <DataTable
        v-model:filters="filters"
        :value="records"
        paginator
        :rows="10"
        data-key="id"
        filter-display="row"
        :loading="loading"
        :global-filter-fields="[
          'rank',
          'points',
          'result',
          'expand.wrestler.name',
          'expand.wrestler.vorname',
          'expand.place.name',
          'expand.place.year',
        ]"
      >
        <template #header>
          <div class="flex justify-content-end">
            <span class="p-input-icon-left">
              <i class="pi pi-search" />
              <InputText
                v-model="filters['global'].value"
                placeholder="Stichwortsuche"
              />
            </span>
          </div>
        </template>
        <template #empty> Keine Kämpfe gefunden. </template>
        <template #loading> Kämpfe wird geladen. Bitte warten. </template>
        <Column field="rank" header="Rang" style="min-width: 12rem">
          <template #body="{ data }">
            {{ data.rank }}
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
        <Column field="points" header="Punkte" style="min-width: 12rem">
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
        <Column field="result" header="Resultat" style="min-width: 12rem">
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
          field="wrestler_name"
          header="Name"
          filter-field="expand.wrestler.name"
          style="min-width: 12rem"
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
          style="min-width: 12rem"
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
          style="min-width: 12rem"
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
  </div>
</template>
