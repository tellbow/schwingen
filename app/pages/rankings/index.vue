<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);
const expandedRows = ref();
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

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";

const filters = ref({
  rank: { value: "", matchMode: FilterMatchMode.EQUALS, prefix: 'rank = "' },
  points: {
    value: "",
    matchMode: FilterMatchMode.EQUALS,
    prefix: 'points = "',
  },
  final: {
    value: "",
    matchMode: FilterMatchMode.EQUALS,
    prefix: "final = ",
  },
  result: {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'result ~ "',
  },
  wreath: {
    value: "",
    matchMode: FilterMatchMode.EQUALS,
    prefix: "wreath = ",
  },
  status: {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'status ~ "',
  },
  "expand.wrestler.name": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'wrestler.name ~ "',
  },
  "expand.wrestler.vorname": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'wrestler.vorname ~ "',
  },
  "expand.place.name": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'place.name ~ "',
  },
  "expand.place.year": {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'place.year >= "2015" && place.year ~ "',
  },
});

const sorts = ref({
  field: "place.year,",
  order: "-",
});

const matchModeOptionEquals = ref([
  { label: "Gleich", value: FilterMatchMode.EQUALS },
]);
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

  pocketbase
    .collection("rankings")
    .getList(page.value, 10, {
      expand: "wrestler,place",
      filter: Object.values(filters.value)
        .map((filter) => {
          const { value, prefix } = filter;
          if (value && value !== "") {
            if (!prefix.includes('"')) {
              return prefix + value;
            }
            return prefix + value + '"';
          }
          return "";
        })
        .filter(Boolean)
        .join(" && "),
      sort: sorts.value.order + sorts.value.field + "-created",
      fields:
        "id,rank,rank2,points,final,result,wreath,status,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.place.id,expand.place.name,expand.place.year",
    })
    .then((data: { totalItems: number; items: any }) => {
      records.value = data.items.map((item: any) => ({
        ...item,
        year: item.expand.place.year.split(" ")[0],
        bouts: [],
      }));
      totalRecords.value = data.totalItems;
      loading.value = false;
    });
};

const loadLazySubData = (wrestlerId: string, placeId: string) => {
  loading.value = true;
  pocketbase
    .collection("bouts")
    // might be a bug to set page.value here
    .getList(page.value, 10, {
      expand: "opponent",
      filter:
        "wrestler.id = '" + wrestlerId + "' && place.id = '" + placeId + "'",
      sort: "fight_round,-created",
      fields:
        "id,result,points,fight_round,expand.opponent.id,expand.opponent.name,expand.opponent.vorname",
    })
    .then((data: { items: any }) => {
      records.value.forEach((item: any) => {
        if (
          item.expand.wrestler.id === wrestlerId &&
          item.expand.place.id === placeId
        ) {
          item.bouts = data.items;
        }
      });
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
  sorts.value.field = event.sortField.replace("_", ".") + ",";
  sorts.value.order = event.sortOrder > 0 ? "" : "-";
  loadLazyData();
};

const onRowExpand = (event: {
  data: {
    expand: {
      wrestler: { id: string };
      place: { id: string };
    };
  };
}) => {
  loadLazySubData(event.data.expand.wrestler.id, event.data.expand.place.id);
};

const onRowCollapse = (event: {
  data: {
    id: string;
  };
}) => {
  const objIndex = records.value.findIndex(
    (obj: { id: string }) => obj.id === event.data.id,
  );
  records.value[objIndex].bouts = [];
};
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
  >
    <DataTable
      v-model:filters="filters"
      v-model:expanded-rows="expandedRows"
      class="w-11 cursor-pointer"
      :value="records"
      resizable-columns
      column-resize-mode="fit"
      show-gridlines
      table-style="min-width: 50rem"
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
      @sort="onSort($event)"
      @row-expand="onRowExpand($event)"
      @row-collapse="onRowCollapse($event)"
    >
      <template #empty> Keine Ranglisten gefunden. </template>
      <template #loading> Ranglisten werden geladen. Bitte warten. </template>
      <Column expander style="width: 4rem" />
      <Column
        field="rank"
        header="Rang"
        style="min-width: 6rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionEquals"
        :show-filter-menu="false"
        :pt="{
          filterInput: { class: 'w-fit' },
        }"
      >
        <template #body="{ data }"> {{ data.rank }}{{ data.rank2 }} </template>
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
      <Column
        field="points"
        header="Punkte"
        style="min-width: 6rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionEquals"
        :show-filter-menu="false"
        :pt="{
          filterInput: { class: 'w-fit' },
        }"
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
        v-if="layout === 'default'"
        field="final"
        header="Schlussgang"
        style="min-width: 6rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionEquals"
        :show-filter-menu="false"
        :show-clear-button="false"
        :pt="{
          filterInput: { class: 'w-fit' },
        }"
      >
        <template #body="{ data }">
          <Icon v-if="data.final" name="gis:flag-finish" />
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <Checkbox
            v-model="filterModel.value"
            :binary="true"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <Column
        field="result"
        header="Resultat"
        style="min-width: 6rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionContains"
        :show-filter-menu="false"
        :pt="{
          filterInput: { class: 'w-fit' },
        }"
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
        v-if="layout === 'default'"
        field="wreath"
        header="Kranz"
        style="min-width: 6rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionEquals"
        :show-filter-menu="false"
        :show-clear-button="false"
        :pt="{
          filterInput: { class: 'w-fit' },
        }"
      >
        <template #body="{ data }">
          <Icon v-if="data.wreath" name="mingcute:wreath-fill" />
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <Checkbox
            v-model="filterModel.value"
            :binary="true"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <Column
        v-if="layout === 'default'"
        field="status"
        header="Status"
        style="min-width: 6rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionEquals"
        :show-filter-menu="false"
        :pt="{
          filterInput: { class: 'w-fit' },
        }"
      >
        <template #body="{ data }">
          {{ data.status }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Filter Status"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <Column
        field="wrestler_name"
        header="Name"
        filter-field="expand.wrestler.name"
        style="min-width: 12rem; padding: 0.5rem"
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
        field="wrestler_vorname"
        header="Vorname"
        filter-field="expand.wrestler.vorname"
        style="min-width: 12rem; padding: 0.5rem"
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
        field="place_name"
        header="Schwingfest"
        filter-field="expand.place.name"
        style="min-width: 12rem; padding: 0.5rem"
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
        field="place_year"
        header="Jahr"
        filter-field="expand.place.year"
        style="min-width: 10rem; padding: 0.5rem"
        sortable
        :show-filter-menu="false"
        :show-clear-button="false"
        :pt="{
          filterInput: { class: 'w-fit' },
        }"
      >
        <template #body="{ data }">
          {{ data.year }}
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
      <template #expansion="data">
        <div class="p-1">
          <DataTable :value="data.data.bouts">
            <Column field="result" header="Resultat" />
            <Column field="points" header="Punkte" sortable />
            <Column field="fight_round" header="Gang" sortable />
            <Column
              field="expand.opponent.name"
              header="Gegner - Name"
              sortable
            />
            <Column
              field="expand.opponent.vorname"
              header="Gegner - Vorname"
              sortable
            />
          </DataTable>
        </div>
      </template>
    </DataTable>
  </div>
</template>
