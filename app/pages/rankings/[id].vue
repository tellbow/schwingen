<script setup lang="ts">
const pocketbase = usePocketbase();

const route = useRoute();

const placeData = ref();
const rankingsData = ref();
const loadingPlace = ref(true);
const loadingRankings = ref(true);

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";

onMounted(async () => {
  await pocketbase
    .collection("places")
    .getFirstListItem('id="' + route.params.id + '"', { expand: "placeType" })
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
      sort: "rank, rank2, -created",
      fields:
        "id,rank,rank2,points,final,result,wreath,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname",
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
  // Extract numerical and alphabetical components
  const numA = parseInt(a.rank);
  const numB = parseInt(b.rank);
  const alphaA = a.rank2;
  const alphaB = b.rank2;

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
          <p>Jahr: {{ placeData.year }}</p>
          <p v-if="placeData.expand.placeType">
            Typ: {{ placeData.expand.placeType.type }}
          </p>
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
          <DataView
            :value="rankingsData"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-2 md:col-1">Rang</p>
                <p class="col-2 md:col-1">Punkte</p>
                <p class="col-3 md:col-2">Resultat</p>
                <p class="col-5 md:col-4">Schwinger</p>
                <p v-if="layout === 'default'" class="md:col-2">Schlussgang</p>
                <p v-if="layout === 'default'" class="md:col-2">Kranz</p>
              </div>
            </template>
            <template #list="slotProps">
              <div
                class="col-12 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.expand.wrestler.id)"
              >
                <div class="grid">
                  <div class="col-2 md:col-1">
                    <p>{{ slotProps.data.rank }}{{ slotProps.data.rank2 }}</p>
                  </div>
                  <div class="col-2 md:col-1">
                    <p>{{ slotProps.data.points }}</p>
                  </div>
                  <div class="col-3 md:col-2">
                    <p>{{ slotProps.data.result }}</p>
                  </div>
                  <div class="col-5 md:col-4">
                    <p>
                      {{ slotProps.data.expand.wrestler.name }}
                      {{ slotProps.data.expand.wrestler.vorname }}
                    </p>
                  </div>
                  <div v-if="layout === 'default'" class="md:col-2">
                    <Icon v-if="slotProps.data.final" name="gis:flag-finish" />
                  </div>
                  <div v-if="layout === 'default'" class="md:col-2">
                    <Icon
                      v-if="slotProps.data.wreath"
                      name="mingcute:wreath-fill"
                    />
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
