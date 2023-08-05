<script setup lang="ts">
const pocketbase = usePocketbase();

const op = ref();
const loadingAverageRank = ref(true);
const averageRank = ref();
const loadingAveragePoints = ref(true);
const averagePoints = ref();
const loadingMostWins = ref(true);
const mostWins = ref();
const loadingMostPlacesAttended = ref(true);
const mostPlacesAttended = ref();
const loadingDrawDecisionRatio = ref(true);
const drawDecisionRatio = ref();
const selectedYear = ref({ year: "Alle" });
const years = ref([
  // { year: 1998 },
  // { year: 2000 },
  // { year: 2001 },
  // { year: 2002 },
  // { year: 2003 },
  // { year: 2004 },
  // { year: 2005 },
  // { year: 2006 },
  // { year: 2007 },
  // { year: 2008 },
  // { year: 2009 },
  // { year: 2010 },
  // { year: 2011 },
  // { year: 2012 },
  // { year: 2013 },
  // { year: 2014 },
  { year: 2015 },
  { year: 2016 },
  { year: 2017 },
  { year: 2018 },
  { year: 2019 },
  // { year: 2020 },
  { year: 2021 },
  { year: 2022 },
  { year: 2023 },
  { year: "Alle" },
]);

/* eslint require-await: "off" */
onMounted(async () => {
  await loadData();
});

const toggle = (event: any) => {
  op.value.toggle(event);
};

const loadData = async () => {
  let loadYear, yearFormatFilter;
  if (selectedYear.value.year === "Alle") {
    loadYear = "Overall";
    yearFormatFilter = "%";
  } else {
    loadYear = selectedYear.value.year;
    yearFormatFilter = selectedYear.value.year;
  }
  await pocketbase
    .collection("averageRank" + loadYear)
    .getFullList(5 /* batch size */, {
      fields: "averageRank,wid,name,vorname,year",
    })
    .then((data) => {
      averageRank.value = data.map((item) => {
        return {
          ...item,
          avgRank: Math.round(item.averageRank * 100) / 100,
        };
      });
      loadingAverageRank.value = false;
    });
  await pocketbase
    .collection("averagePoints" + loadYear)
    .getFullList(5 /* batch size */, {
      fields: "averagePoints,wid,name,vorname,year",
    })
    .then((data) => {
      averagePoints.value = data.map((item) => {
        return {
          ...item,
          avgPoints: Math.round(item.averagePoints * 100) / 100,
        };
      });
      loadingAveragePoints.value = false;
    });
  await pocketbase
    .collection("mostWins" + loadYear)
    .getFullList(5 /* batch size */, {
      fields: "wins,wreath,id,name,vorname",
    })
    .then((data) => {
      mostWins.value = data;
      loadingMostWins.value = false;
    });
  await pocketbase
    .collection("mostPlacesAttended" + loadYear)
    .getFullList(5 /* batch size */, {
      fields: "placesAttended,id,name,vorname,year",
    })
    .then((data) => {
      mostPlacesAttended.value = data;
      loadingMostPlacesAttended.value = false;
    });
  await pocketbase
    .collection("drawDecisionRatio")
    .getFullList(1 /* batch size */, {
      filter: "yearFormat ~ '" + yearFormatFilter + "'",
      fields: "countDraw,countAll,yearFormat",
    })
    .then((data) => {
      const sumDraw = data.reduce((accumulator, object) => {
        const valueDraw = object.countDraw;
        return accumulator + valueDraw;
      }, 0);
      const sumAll = data.reduce((accumulator, object) => {
        const valueAll = object.countAll;
        return accumulator + valueAll;
      }, 0);
      drawDecisionRatio.value = Math.round((sumDraw / sumAll) * 100);
      loadingDrawDecisionRatio.value = false;
    });
};

async function yearSelected() {
  await loadData();
}

async function rowClick(wid: any) {
  await navigateTo("/wrestler/" + wid);
}
</script>
<template>
  <div class="card">
    <div class="flex items-center justify-center mt-2 md:mt-4">
      <p class="ml-2 md:ml-4 text-lg md:text-xl text-stone-700 font-bold">
        Jahr:
      </p>
      <Dropdown
        v-model="selectedYear"
        :options="years"
        option-label="year"
        placeholder="Wähle ein Jahr"
        class="w-fit ml-4 text-stone-700 font-bold"
        @change="yearSelected()"
      />
    </div>
    <div
      class="justify-center flex md:align-items-center align-items-stretch flex-wrap"
    >
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title>
          Top 5 - ⌀ Rang
          <Badge value="?" @click="toggle"></Badge>
          <OverlayPanel ref="op">5 Teilnahmen pro Jahr oder mehr</OverlayPanel>
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingAverageRank" />
          <DataView
            v-else
            :value="averageRank"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-8 md:col-6">Schwinger</p>
                <p class="col-1 md:col-1">Rang</p>
              </div>
            </template>
            <template #list="slotProps">
              <div
                class="col-12 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.wid)"
              >
                <div class="grid">
                  <div class="col-1 md:col-1 flex justify-center items-center">
                    <p>{{ slotProps.index + 1 }}</p>
                  </div>
                  <div class="col-8 md:col-6">
                    <p>
                      {{ slotProps.data.name }} {{ slotProps.data.vorname }}
                    </p>
                  </div>
                  <div class="col-1 md:col-1">
                    <p>{{ slotProps.data.avgRank }}</p>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title>
          Top 5 - ⌀ Punkte
          <Badge value="?" @click="toggle"></Badge>
          <OverlayPanel ref="op">5 Teilnahmen pro Jahr oder mehr</OverlayPanel>
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingAveragePoints" />
          <DataView
            v-else
            :value="averagePoints"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-8 md:col-6">Schwinger</p>
                <p class="col-1 md:col-1">Punkte</p>
              </div>
            </template>
            <template #list="slotProps">
              <div
                class="col-12 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.wid)"
              >
                <div class="grid">
                  <div class="col-1 md:col-1 flex justify-center items-center">
                    <p>{{ slotProps.index + 1 }}</p>
                  </div>
                  <div class="col-8 md:col-6">
                    <p>
                      {{ slotProps.data.name }} {{ slotProps.data.vorname }}
                    </p>
                  </div>
                  <div class="col-1 md:col-1">
                    <p>{{ slotProps.data.avgPoints }}</p>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Top 5 - meiste Siege </template>
        <template #content>
          <ProgressSpinner v-if="loadingMostWins" />
          <DataView
            v-else
            :value="mostWins"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-6 md:col-6">Schwinger</p>
                <p class="col-2 md:col-1">Siege</p>
                <p class="col-3 md:col-3">mit Kranz</p>
              </div>
            </template>
            <template #list="slotProps">
              <div
                class="col-12 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.wid)"
              >
                <div class="grid">
                  <div class="col-1 md:col-1 flex justify-center items-center">
                    <p>{{ slotProps.index + 1 }}</p>
                  </div>
                  <div class="col-6 md:col-6">
                    <p>
                      {{ slotProps.data.name }} {{ slotProps.data.vorname }}
                    </p>
                  </div>
                  <div class="col-2 md:col-1">
                    <p>{{ slotProps.data.wins }}</p>
                  </div>
                  <div class="col-3 md:col-3">
                    <p>{{ slotProps.data.wreath }}</p>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Top 5 - meiste Teilnahmen </template>
        <template #content>
          <ProgressSpinner v-if="loadingMostPlacesAttended" />
          <DataView
            v-else
            :value="mostPlacesAttended"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-7 md:col-6">Schwinger</p>
                <p class="col-2 md:col-1">Teilnahmen</p>
              </div>
            </template>
            <template #list="slotProps">
              <div
                class="col-12 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.wid)"
              >
                <div class="grid">
                  <div class="col-1 md:col-1 flex justify-center items-center">
                    <p>{{ slotProps.index + 1 }}</p>
                  </div>
                  <div class="col-7 md:col-6">
                    <p>
                      {{ slotProps.data.name }} {{ slotProps.data.vorname }}
                    </p>
                  </div>
                  <div class="col-2 md:col-1">
                    <p>{{ slotProps.data.placesAttended }}</p>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 w-screen md:w-5">
        <template #title> % Gestellte Gänge </template>
        <template #content>
          <ProgressSpinner v-if="loadingDrawDecisionRatio" />
          <ul v-else>
            <p>{{ drawDecisionRatio }}</p>
          </ul>
        </template>
      </Card>
    </div>
  </div>
</template>
