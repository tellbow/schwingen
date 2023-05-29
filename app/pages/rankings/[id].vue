<script setup lang="ts">
const pocketbase = usePocketbase();

const route = useRoute();

const placeData = ref();
const rankingsData = ref();
const loadingPlace = ref(true);
const loadingRankings = ref(true);

onMounted(async () => {
  await pocketbase
    .collection("places")
    .getFirstListItem('id="' + route.params.id + '"', {})
    .then((data) => {
      data.year = data.year.split("-")[0];
      placeData.value = data;
      loadingPlace.value = false;
    });
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      filter: 'place.id = "' + route.params.id + '"',
      expand: "wrestler",
      sort: "rank, -created",
      fields:
        "id,rank,points,result,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname",
    })
    .then((data) => {
      rankingsData.value = data.sort(compareByRank);
      loadingRankings.value = false;
    });
});

async function rowClick(id: any) {
  await navigateTo("/wrestler/" + id);
}

// Custom comparator function to sort by rank
const compareByRank = (a: any, b: any) => {
  const rankA = a.rank;
  const rankB = b.rank;

  // Extract numerical and alphabetical components
  const numA = parseInt(rankA);
  const numB = parseInt(rankB);
  const alphaA = rankA.slice(-1);
  const alphaB = rankB.slice(-1);

  // Compare numerical components
  if (numA !== numB) {
    return numA - numB;
  }

  // If numerical components are equal, compare alphabetical components
  return alphaA.localeCompare(alphaB);
};
</script>
<template>
  <div>
    <ProgressSpinner v-if="loadingPlace" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title> Schwingfest: {{ placeData.name }} </template>
        <template #content>
          <p>Ort: {{ placeData.location }}</p>
          <p>Ort: {{ placeData.year }}</p>
        </template>
      </Card>
    </div>
    <ProgressSpinner v-if="loadingRankings" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title> Rangliste </template>
        <template #content>
          <DataView :value="rankingsData" data-key="id">
            <template #list="slotProps">
              <div
                class="col-12 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.expand.wrestler.id)"
              >
                <div class="grid">
                  <div class="col-1">
                    <p>{{ slotProps.data.rank }}</p>
                  </div>
                  <div class="col-2">
                    <p>{{ slotProps.data.points }}</p>
                  </div>
                  <div class="col-3">
                    <p>{{ slotProps.data.result }}</p>
                  </div>
                  <div class="col-6">
                    <p>
                      {{ slotProps.data.expand.wrestler.name }}
                      {{ slotProps.data.expand.wrestler.vorname }}
                    </p>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
    </div>
  </div>
</template>
