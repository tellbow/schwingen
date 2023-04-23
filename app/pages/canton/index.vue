<script setup lang="ts">
import { FilterMatchMode } from 'primevue/api'

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

onMounted(async () => {
  await pocketbase.collection('canton').getFullList(200 /* batch size */, {
    sort: 'name,-created',
    expand: 'association',
  }).then((data) => {
    records.value = data;
    loading.value = false;
  });
});

const filters = ref({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS },
    name: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.association.name': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
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
      :global-filter-fields="['name','expand.association.name']"
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
        Keine Kantone gefunden.
      </template>
      <template #loading>
        Kantone werden geladen. Bitte warten.
      </template>
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
        field="association"
        header="Verband"
        filter-field="expand.association.name"
        style="min-width: 12rem"
      >
        <template #body="{ data }">
          {{ data.expand.association.name }}
        </template>
        <template #filter="{ filterModel, filterCallback }">
          <InputText
            v-model="filterModel.value"
            type="text"
            class="p-column-filter"
            placeholder="Filter Verband"
            @input="filterCallback()"
          />
        </template>
      </Column>
    </DataTable>
  </div>
</template>
