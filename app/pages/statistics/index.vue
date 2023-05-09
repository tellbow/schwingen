<script setup lang="ts">
const pocketbase = usePocketbase();

const loadingAverageRank = ref(true);
const averageRank = ref();
const loadingAveragePoints = ref(true);
const averagePoints = ref();
const selectedYear = ref({ year: 2022 });
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
  // { year: 2015 },
  // { year: 2016 },
  // { year: 2017 },
  // { year: 2018 },
  // { year: 2019 },
  // { year: 2020 },
  // { year: 2021 },
  { year: 2022 },
  { year: 2023 },
]);

/* eslint require-await: "off" */
onMounted(async () => {
  await loadData();
});

const loadData = async () => {
  await pocketbase
    .collection("averageRank" + selectedYear.value.year)
    .getFullList()
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
    .collection("averagePoints" + selectedYear.value.year)
    .getFullList()
    .then((data) => {
      averagePoints.value = data.map((item) => {
        return {
          ...item,
          avgPoints: Math.round(item.averagePoints * 100) / 100,
        };
      });
      loadingAveragePoints.value = false;
    });
};

async function yearSelected() {
  await loadData();
}
</script>
<template>
  <div class="card">
    <p class="mt-2 ml-2">Jahr:</p>
    <Dropdown
      v-model="selectedYear"
      :options="years"
      option-label="year"
      placeholder="Wähle ein Jahr"
      class="w-full md:w-14rem mt-1 ml-2"
      @change="yearSelected()"
    />
    <Card class="mt-2">
      <template #title> Top 5 - ⌀ Rang (mit 5 Teilnahmen oder mehr) </template>
      <template #content>
        <ProgressSpinner v-if="loadingAverageRank" />
        <ul v-else>
          <li v-for="(item, index) in averageRank" :key="item.id">
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgRank }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="mt-2">
      <template #title>
        Top 5 - ⌀ Punkte (mit 5 Teilnahmen oder mehr)
      </template>
      <template #content>
        <ProgressSpinner v-if="loadingAveragePoints" />
        <ul v-else>
          <li v-for="(item, index) in averagePoints" :key="item.id">
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgPoints }}
          </li>
        </ul>
      </template>
    </Card>
  </div>
</template>
