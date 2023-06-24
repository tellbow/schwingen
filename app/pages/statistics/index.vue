<script setup lang="ts">
const pocketbase = usePocketbase();

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
      fields: "wins,id,name,vorname",
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
    <div class="flex items-center justify-start mt-2 md:mt-4">
      <p class="ml-4 text-lg md:text-xl text-stone-700 font-bold">Jahr:</p>
      <Dropdown
        v-model="selectedYear"
        :options="years"
        option-label="year"
        placeholder="Wähle ein Jahr"
        class="w-fit ml-4 text-stone-700 font-bold"
        @change="yearSelected()"
      />
    </div>
    <Card class="ml-4 mt-2 mr-4">
      <template #title> Top 5 - ⌀ Rang (mit 5 Teilnahmen oder mehr) </template>
      <template #content>
        <ProgressSpinner v-if="loadingAverageRank" />
        <ul v-else>
          <li
            v-for="(item, index) in averageRank"
            :key="item.wid"
            class="hover:bg-gray-200 cursor-pointer"
            @click="rowClick(item.wid)"
          >
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgRank }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="ml-4 mt-2 mr-4">
      <template #title>
        Top 5 - ⌀ Punkte (mit 5 Teilnahmen oder mehr)
      </template>
      <template #content>
        <ProgressSpinner v-if="loadingAveragePoints" />
        <ul v-else>
          <li
            v-for="(item, index) in averagePoints"
            :key="item.wid"
            class="hover:bg-gray-200 cursor-pointer"
            @click="rowClick(item.wid)"
          >
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgPoints }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="ml-4 mt-2 mr-4">
      <template #title> Top 5 - meiste Siege </template>
      <template #content>
        <ProgressSpinner v-if="loadingMostWins" />
        <ul v-else>
          <li
            v-for="(item, index) in mostWins"
            :key="item.id"
            class="hover:bg-gray-200 cursor-pointer"
            @click="rowClick(item.id)"
          >
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.wins }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="ml-4 mt-2 mr-4">
      <template #title> Top 5 - meiste Teilnahmen </template>
      <template #content>
        <ProgressSpinner v-if="loadingMostPlacesAttended" />
        <ul v-else>
          <li
            v-for="(item, index) in mostPlacesAttended"
            :key="item.id"
            class="hover:bg-gray-200 cursor-pointer"
            @click="rowClick(item.id)"
          >
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.placesAttended }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="ml-4 mt-2 mr-4">
      <template #title> % Gestellte Gänge </template>
      <template #content>
        <ProgressSpinner v-if="loadingDrawDecisionRatio" />
        <ul v-else>
          <p>{{ drawDecisionRatio }}</p>
        </ul>
      </template>
    </Card>
  </div>
</template>
