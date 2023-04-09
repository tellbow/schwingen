<script setup lang="ts">
import { FilterMatchMode } from 'primevue/api'

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

onMounted(async () => {
  await pocketbase.collection('club').getFullList(200 /* batch size */, {
    sort: 'name,-created',
    expand: 'canton',
  }).then((data) => {
    records.value = data;
    loading.value = false;
  });
});

const filters = ref({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS },
    name: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.canton.name': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
});
</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5">
    <DataTable v-model:filters="filters" :value="records" paginator :rows="10" dataKey="id" filterDisplay="row" :loading="loading"
                :globalFilterFields="['name','expand.canton.name']">
            <template #header>
                <div class="flex justify-content-end">
                    <span class="p-input-icon-left">
                        <i class="pi pi-search" />
                        <InputText v-model="filters['global'].value" placeholder="Stichwortsuche" />
                    </span>
                </div>
            </template>
            <template #empty> Keine Schwingvereine gefunden. </template>
            <template #loading> Schwingvereine werden geladen. Bitte warten. </template>
            <Column field="name" header="Name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Name" />
                </template>
            </Column>
            <Column field="canton" header="Kanton" filterField="expand.canton.name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.canton.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Kanton" />
                </template>
            </Column>
        </DataTable>
  </div>
</template>
