<script setup lang="ts">
import { FilterMatchMode } from 'primevue/api'

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

onMounted(async () => {
  await pocketbase.collection('association').getFullList(200 /* batch size */, {
    sort: 'name,-created',
  }).then((data) => {
    records.value = data;
    loading.value = false;
  });
});

const filters = ref({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS },
    name: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    abbreviation: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
});
</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5">
    <DataTable v-model:filters="filters" :value="records" paginator :rows="10" dataKey="id" filterDisplay="row" :loading="loading"
                :globalFilterFields="['name','abbreviation']">
            <template #header>
                <div class="flex justify-content-end">
                    <span class="p-input-icon-left">
                        <i class="pi pi-search" />
                        <InputText v-model="filters['global'].value" placeholder="Stichwortsuche" />
                    </span>
                </div>
            </template>
            <template #empty> Keine Verbände gefunden. </template>
            <template #loading> Verbände werden geladen. Bitte warten. </template>
            <Column field="name" header="Name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Name" />
                </template>
            </Column>
            <Column field="abbreviation" header="Abkürzung" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.abbreviation }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Abkürzung" />
                </template>
            </Column>
        </DataTable>
  </div>
</template>
