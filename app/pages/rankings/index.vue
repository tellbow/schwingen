<script setup lang="ts">
import { FilterMatchMode } from "primevue/api";

const pocketbase = usePocketbase();

const loading = ref(true);
const page = ref(1);
const records = ref();
const totalRecords = ref(0);
const expandedRows = ref();

const filters = ref({
  rank: { value: "", matchMode: FilterMatchMode.EQUALS, prefix: 'rank = "' },
  points: {
    value: "",
    matchMode: FilterMatchMode.EQUALS,
    prefix: 'points = "',
  },
  result: {
    value: "",
    matchMode: FilterMatchMode.CONTAINS,
    prefix: 'result ~ "',
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
    prefix: 'place.year ~ "',
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
    .getList(page.value, 15, {
      expand: "wrestler,place",
      filter: Object.values(filters.value)
        .map((filter) => {
          const { value, prefix } = filter;
          if (value && value !== "") {
            return prefix + value + '"';
          }
          return "";
        })
        .filter(Boolean)
        .join(" && "),
      sort: sorts.value.order + sorts.value.field + "-created",
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
    .getList(page.value, 15, {
      expand: "opponent",
      filter:
        "wrestler.id = '" + wrestlerId + "' && place.id = '" + placeId + "'",
      sort: "fight_round,-created",
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
    (obj: { id: string }) => obj.id === event.data.id
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
      :rows="15"
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
      <Column expander style="width: 5rem" />
      <Column
        field="rank"
        header="Rang"
        style="min-width: 12rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionEquals"
      >
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
      <Column
        field="points"
        header="Punkte"
        style="min-width: 12rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionEquals"
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
        field="result"
        header="Resultat"
        style="min-width: 12rem; padding: 0.5rem"
        :filter-match-mode-options="matchModeOptionContains"
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
        field="wrestler_name"
        header="Name"
        filter-field="expand.wrestler.name"
        style="min-width: 12rem; padding: 0.5rem"
        sortable
        :filter-match-mode-options="matchModeOptionContains"
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
        style="min-width: 12rem; padding: 0.5rem"
        sortable
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
            placeholder="Filter Jahr"
            @input="filterCallback()"
          />
        </template>
      </Column>
      <template #expansion="data">
        <div class="p-1">
          <DataTable :value="data.data.bouts">
            <Column field="result" header="Resultat"></Column>
            <Column field="points" header="Punkte" sortable></Column>
            <Column field="fight_round" header="Gang" sortable></Column>
            <Column
              field="expand.opponent.name"
              header="Gegner - Name"
              sortable
            ></Column>
            <Column
              field="expand.opponent.vorname"
              header="Gegner - Vorname"
              sortable
            ></Column>
          </DataTable>
        </div>
      </template>
    </DataTable>
  </div>
</template>
