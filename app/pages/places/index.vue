<script setup lang="ts">
import { FilterMatchMode } from 'primevue/api'

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

onMounted(async () => {
  await pocketbase.collection('places').getFullList(200 /* batch size */, {
    sort: 'name,-created',
  }).then((data) => {
    records.value = data;
    loading.value = false;
  });
});

const filters = ref({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS },
    number: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    name: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    location: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    year: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
});
</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5">
    <DataTable
      v-model:filters="filters"
      :value="records"
      paginator
      :rows="10"
      data-key="id"
      filter-display="row"
      :loading="loading"
      :global-filter-fields="['number','name','location','year']"
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
      <template #empty>
        Keine Schwingfeste gefunden.
      </template>
      <template #loading>
        Schwingfeste werden geladen. Bitte warten.
      </template>
      <Column
        field="number"
        header="Nummer"
        style="min-width: 12rem"
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
        style="min-width: 12rem"
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
        field="location"
        header="Ort"
        style="min-width: 12rem"
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
        style="min-width: 12rem"
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
