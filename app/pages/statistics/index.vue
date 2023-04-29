<script setup lang="ts">
const pocketbase = usePocketbase();

const loadingRankings = ref(true);
const rankingsData = ref();

/* eslint require-await: "off" */
onMounted(async () => {
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      expand: "wrestler",
      sort: "-created",
    })
    .then((data) => {
      rankingsData.value = data;
      loadingRankings.value = false;
    });
});

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

    avgRankById.sort((a, b) => a.avgRank - b.avgRank);

    return avgRankById;
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

    avgPointsById.sort((a, b) => a.avgPoints - b.avgPoints);

    return avgPointsById;
  },
  set: () => {},
});
</script>
<template>
  <div class="card">
    <Card class="mt-2">
      <template #title> Top 5 - ⌀ Rang </template>
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
      <template #title> Bottom 5 - ⌀ Rang </template>
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
      <template #title> Top 5 - ⌀ Punkte </template>
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
      <template #title> Bottom 5 - ⌀ Punkte </template>
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
