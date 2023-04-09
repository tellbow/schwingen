<script setup lang="ts">
import { FilterMatchMode } from 'primevue/api'

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

onMounted(async () => {
  await pocketbase.collection('bouts').getFullList(200 /* batch size */, {
    sort: '-created',
    expand: 'wrestler1,wrestler2,place',
  }).then((data) => {
    records.value = data;
    loading.value = false;
  });
});

const filters = ref({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS },
    'expand.wrestler1.name': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.wrestler1.vorname': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    level: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    points: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    fight_round: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.wrestler2.name': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.wrestler2.vorname': { value: null, matchMode: FilterMatchMode.STARTS_WITH },
    'expand.place.name': { value: null, matchMode: FilterMatchMode.STARTS_WITH }
});

</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5">
    <DataTable v-model:filters="filters" :value="records" paginator :rows="10" dataKey="id" filterDisplay="row" :loading="loading"
                :globalFilterFields="['expand.wrestler1.name','expand.wrestler1.vorname','level','points','fight_round','expand.wrestler2.name','expand.wrestler2.vorname','expand.place.name']">
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
            <Column field="wrestler1_name" header="Schwinger 1 - Name" filterField="expand.wrestler1.name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.wrestler1.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Schwinger 1 - Name" />
                </template>
            </Column>
            <Column field="wrestler1_vorname" header="Schwinger 1 - Vorname" filterField="expand.wrestler1.vorname" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.wrestler1.vorname }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Schwinger 1 - Vorname" />
                </template>
            </Column>
            <Column field="level" header="Schwingerstatus" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.level }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Schwingerstatus" />
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
            <Column field="fight_round" header="Gang" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.fight_round }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Gang" />
                </template>
            </Column>
            <Column field="wrestler2_name" header="Schwinger 2 - Name" filterField="expand.wrestler2.name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.wrestler2.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Schwinger 2 - Name" />
                </template>
            </Column>
            <Column field="wrestler2_vorname" header="Schwinger 2 - Vorname" filterField="expand.wrestler2.vorname" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.wrestler2.vorname }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Schwinger 2 - Vorname" />
                </template>
            </Column>
            <Column field="place" header="Schwingfest" filterField="expand.place.name" style="min-width: 12rem">
                <template #body="{ data }">
                    {{ data.expand.place.name }}
                </template>
                <template #filter="{ filterModel, filterCallback }">
                    <InputText v-model="filterModel.value" type="text" @input="filterCallback()" class="p-column-filter" placeholder="Filter Schwingfest" />
                </template>
            </Column>
        </DataTable>
  </div>
</template>
