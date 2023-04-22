<script setup lang="ts">
import { FilterMatchMode } from 'primevue/api'

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

onMounted(async () => {
  await pocketbase.collection('rankings').getFullList(200 /* batch size */, {
    sort: '-created',
    expand: 'wrestler,place',
  }).then((data) => {
    records.value = data;
    loading.value = false;
  });
});

const filters = ref({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS },
    rank: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    points: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    result: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.wrestler.name': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.wrestler.vorname': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.place.name': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.place.year': { value: null, matchMode: FilterMatchMode.STARTS_WITH }
});

</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5">
    <DataTable v-model:filters="filters" :value="records" paginator :rows="10" dataKey="id" filterDisplay="row" :loading="loading"
                :globalFilterFields="['rank','points','result','expand.wrestler.name','expand.wrestler.vorname','expand.place.name','expand.place.year']">
            <template #header>
                <div class="flex justify-content-end">
                    <span class="p-input-icon-left">
                        <i class="pi pi-search" />
                        <InputText v-model="filters['global'].value" placeholder="Stichwortsuche" />
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
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Rang" />
                </template>
            </Column>
            <Column field="points" header="Punkte" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.points }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Punkte" />
                </template>
            </Column>
            <Column field="result" header="Resultat" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.result }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Resultat" />
                </template>
            </Column>
            <Column field="wrestler_name" header="Name" filterField="expand.wrestler.name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.wrestler.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Name" />
                </template>
            </Column>
            <Column field="wrestler_vorname" header="Vorname" filterField="expand.wrestler.vorname" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.wrestler.vorname }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Vorname" />
                </template>
            </Column>
            <Column field="place_name" header="Schwingfest" filterField="expand.place.name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.place.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Schwingfest" />
                </template>
            </Column>
            <Column field="place_year" header="Jahr" filterField="expand.place.year" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.place.year }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Jahr" />
                </template>
            </Column>
        </DataTable>
  </div>
</template>
