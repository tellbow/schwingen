<script setup lang="ts">
const pocketbase = usePocketbase();

const op = ref();
const op2 = ref();
const loadingElo = ref(true);
const eloData = ref();
const loadingAverageRank = ref(true);
const averageRank = ref();
const loadingAveragePoints = ref(true);
const averagePoints = ref();
const loadingMostWins = ref(true);
const mostWins = ref();
const loadingMostPlacesAttended = ref(true);
const mostPlacesAttended = ref();
const loadingMostWreaths = ref(true);
const mostWreaths = ref();
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
  { year: 2024 },
  { year: 2025 },
  { year: "Alle" },
]);

/* eslint require-await: "off" */
onMounted(async () => {
  await loadData();
});

const toggle = (event: any) => {
  op.value.toggle(event);
};

const toggle2 = (event: any) => {
  op2.value.toggle(event);
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
    .collection("elo")
    .getList(1, 5, {
      expand: "wrestler",
      sort: "-rating,-created",
      fields:
        "id,rating,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname",
    })
    .then((data) => {
      eloData.value = data.items;
      loadingElo.value = false;
    });
  await pocketbase
    .collection("averageRank" + loadYear)
    .getList(1, 5, {
      fields: "averageRank,wid,name,vorname,year",
    })
    .then((data) => {
      data.items.forEach((item) => {
        item.avgRank = Math.round(item.averageRank * 100) / 100;
      });
      averageRank.value = data.items;
      loadingAverageRank.value = false;
    });
  await pocketbase
    .collection("averagePoints" + loadYear)
    .getList(1, 5, {
      fields: "averagePoints,wid,name,vorname,year",
    })
    .then((data) => {
      data.items.forEach((item) => {
        item.avgPoints = Math.round(item.averagePoints * 100) / 100;
      });
      averagePoints.value = data.items;
      loadingAveragePoints.value = false;
    });
  await pocketbase
    .collection("mostWins" + loadYear)
    .getList(1, 5, {
      sort: "-wins,-wreath",
      fields: "wins,wreath,id,name,vorname",
    })
    .then((data) => {
      mostWins.value = data.items;
      loadingMostWins.value = false;
    });
  await pocketbase
    .collection("mostPlacesAttended" + loadYear)
    .getList(1, 5, {
      fields: "placesAttended,id,name,vorname,year",
    })
    .then((data) => {
      mostPlacesAttended.value = data.items;
      loadingMostPlacesAttended.value = false;
    });
  await pocketbase
    .collection("mostWreaths" + loadYear)
    .getList(1, 5, {
      fields: "wreath,id,name,vorname",
    })
    .then((data) => {
      mostWreaths.value = data.items;
      loadingMostWreaths.value = false;
    });
  await pocketbase
    .collection("drawDecisionRatio")
    .getList(1, 24, {
      filter: "yearFormat ~ '" + yearFormatFilter + "'",
      fields: "countDraw,countAll,yearFormat",
    })
    .then((data) => {
      let sumAll = 0;
      let sumDraw = 0;
      data.items.forEach((item) => {
        sumDraw += item.countDraw;
        sumAll += item.countAll;
      });
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
          Top 5 - Elo-Rating
          <Badge value="?" @click="toggle2" />
          <OverlayPanel ref="op2">Jeweils vom aktuellen Jahr</OverlayPanel>
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingElo" />
          <DataView
            v-else
            :value="eloData"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-8 md:col-6">Schwinger</p>
                <p class="col-1 md:col-1">Rating</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.expand.wrestler.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-8 md:col-6">
                      <p>
                        {{ item.expand.wrestler.name }}
                        {{ item.expand.wrestler.vorname }}
                      </p>
                    </div>
                    <div class="col-1 md:col-1">
                      <p>{{ item.rating }}</p>
                    </div>
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
          Top 5 - ⌀ Rang
          <Badge value="?" @click="toggle" />
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
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.wid)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-8 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-1 md:col-1">
                      <p>{{ item.avgRank }}</p>
                    </div>
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
          <Badge value="?" @click="toggle" />
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
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.wid)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-8 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-1 md:col-1">
                      <p>{{ item.avgPoints }}</p>
                    </div>
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
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-6 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.wins }}</p>
                    </div>
                    <div class="col-3 md:col-3">
                      <p>{{ item.wreath }}</p>
                    </div>
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
        <template #title> Top 5 - meiste Kränze </template>
        <template #content>
          <ProgressSpinner v-if="loadingMostWreaths" />
          <DataView
            v-else
            :value="mostWreaths"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-7 md:col-6">Schwinger</p>
                <p class="col-2 md:col-1">Kränze</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-7 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.wreath }}</p>
                    </div>
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
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-7 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.placesAttended }}</p>
                    </div>
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
