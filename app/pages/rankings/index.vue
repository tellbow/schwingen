<script setup lang="ts">
import { FilterMatchMode } from 'primevue/api'

const pocketbase = usePocketbase();

const records = ref();
const loading = ref(true);

onMounted(async () => {
    await pocketbase.collection('places').getFullList(200 /* batch size */, {
        sort: '-created',
    }).then((data) => {
        const picked = data.map((item) => {
            return {
                name: item.name + ' ' + item.location + ' ' + item.year.split('-')[0],
            }
        })
        places.value = picked;
    });
    await pocketbase.collection('rankings').getList(1, 50, {
        sort: '-created',
        expand: 'wrestler,place',
    }).then((data) => {
        records.value = data.items;
        loading.value = false;
    });
    // await pocketbase.collection('rankings').getFullList(200 /* batch size */, {
    //     sort: '-created',
    //     expand: 'wrestler,place',
    // }).then((data) => {
    //     records.value = data;
    //     loading.value = false;
    // });
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

const selectedPlaces = ref();
const places = ref();
const cities = ref([
    { name: 'New York', code: 'NY' },
    { name: 'Rome', code: 'RM' },
    { name: 'London', code: 'LDN' },
    { name: 'Istanbul', code: 'IST' },
    { name: 'Paris', code: 'PRS' }
]);
const selectedYears = ref();
const years = ref([
    { year: '1998' },
    { year: '2000' },
    { year: '2001' },
    { year: '2002' },
    { year: '2003' },
    { year: '2004' },
    { year: '2005' },
    { year: '2006' },
    { year: '2007' },
    { year: '2008' },
    { year: '2009' },
    { year: '2010' },
    { year: '2011' },
    { year: '2012' },
    { year: '2013' },
    { year: '2014' },
    { year: '2015' },
    { year: '2016' },
    { year: '2017' },
    { year: '2018' },
    { year: '2019' },
    { year: '2020' },
    { year: '2021' },
    { year: '2022' },
    { year: '2023' },
])
</script>
<template>
  <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5">
    <div class="justify-content-center align-content-center display: flex flex-wrap fill-height mb-2">
        <p class="pt-2 pr-2">Schwingfest(e): </p>
        <MultiSelect v-model="selectedPlaces" display="chip" :options="places" filter optionLabel="name" placeholder="Wähle Schwingest(e)"
        :maxSelectedLabels="3" class="w-full md:w-20rem" />
        <p class="pt-2 pl-10 pr-2">Jahr(e): </p>
        <MultiSelect v-model="selectedYears" display="chip" :options="years" filter optionLabel="year" placeholder="Wähle Jahr(e)"
        :maxSelectedLabels="3" class="w-full md:w-20rem" />
        <Button label="Filtern" class="ml-4" />
    </div>
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
