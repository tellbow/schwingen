<script setup lang="ts">
const pocketbase = usePocketbase();

const loadingRankings = ref(true);
const rankingsData = ref();
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
  // { year: 2023 },
]);

/* eslint require-await: "off" */
onMounted(async () => {
  await loadData();
});

const loadData = async () => {
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      expand: "wrestler",
      filter: 'place.year ~ "' + selectedYear.value.year + '"',
      sort: "-created",
    })
    .then((data) => {
      rankingsData.value = data;
      loadingRankings.value = false;
    });
};

const averageRank = computed({
  get: () => {
    const rankSumCountById = rankingsData.value.reduce(
      (acc: any, item: any) => {
        if (!acc[item.expand.wrestler.id]) {
          acc[item.expand.wrestler.id] = {
            name: item.expand.wrestler.name,
            vorname: item.expand.wrestler.vorname,
            sum: 0,
            count: 0,
          };
        }
        const rank = parseInt(item.rank.match(/^\d+/)[0]);
        acc[item.expand.wrestler.id].sum += rank;
        acc[item.expand.wrestler.id].count++;
        return acc;
      },
      {}
    );

    const avgRankById = Object.keys(rankSumCountById).map((id) => {
      const { name, vorname, sum, count } = rankSumCountById[id];
      const avgRank = Math.round((sum / count) * 100);
      return { id, name, vorname, avgRank };
    });

    const filteredAvgRankById = avgRankById.filter((item) => {
      return rankSumCountById[item.id].count >= 5;
    });

    filteredAvgRankById.sort((a, b) => a.avgRank - b.avgRank);

    return filteredAvgRankById;
  },
  set: () => {},
});

const averagePoints = computed({
  get: () => {
    const pointsSumCountById = rankingsData.value.reduce(
      (acc: any, item: any) => {
        if (!acc[item.expand.wrestler.id]) {
          acc[item.expand.wrestler.id] = {
            name: item.expand.wrestler.name,
            vorname: item.expand.wrestler.vorname,
            sum: 0,
            count: 0,
          };
        }
        const points = parseInt(item.points.match(/^\d+/)[0]);
        acc[item.expand.wrestler.id].sum += points;
        acc[item.expand.wrestler.id].count++;
        return acc;
      },
      {}
    );

    const avgPointsById = Object.keys(pointsSumCountById).map((id) => {
      const { name, vorname, sum, count } = pointsSumCountById[id];
      const avgPoints = Math.round((sum / count) * 100);
      return { id, name, vorname, avgPoints };
    });

    const filteredAvgPointsById = avgPointsById.filter((item) => {
      return pointsSumCountById[item.id].count >= 5;
    });

    filteredAvgPointsById.sort((a, b) => a.avgPoints - b.avgPoints);

    return filteredAvgPointsById;
  },
  set: () => {},
});

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
        <ProgressSpinner v-if="loadingRankings" />
        <ul v-else>
          <li v-for="(item, index) in averageRank.slice(0, 5)" :key="item.id">
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgRank / 100 }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="mt-2">
      <template #title>
        Bottom 5 - ⌀ Rang (mit 5 Teilnahmen oder mehr)
      </template>
      <template #content>
        <ProgressSpinner v-if="loadingRankings" />
        <ul v-else>
          <li
            v-for="(item, index) in averageRank.slice(-5).reverse()"
            :key="item.id"
          >
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgRank / 100 }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="mt-2">
      <template #title>
        Top 5 - ⌀ Punkte (mit 5 Teilnahmen oder mehr)
      </template>
      <template #content>
        <ProgressSpinner v-if="loadingRankings" />
        <ul v-else>
          <li
            v-for="(item, index) in averagePoints.slice(-5).reverse()"
            :key="item.id"
          >
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgPoints / 100 }}
          </li>
        </ul>
      </template>
    </Card>
    <Card class="mt-2">
      <template #title>
        Bottom 5 - ⌀ Punkte (mit 5 Teilnahmen oder mehr)
      </template>
      <template #content>
        <ProgressSpinner v-if="loadingRankings" />
        <ul v-else>
          <li v-for="(item, index) in averagePoints.slice(0, 5)" :key="item.id">
            {{ index + 1 }}: {{ item.name }} {{ item.vorname }} -
            {{ item.avgPoints / 100 }}
          </li>
        </ul>
      </template>
    </Card>
  </div>
</template>
