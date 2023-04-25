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
    })
    .then((data) => {
      rankingsData.value = data;
      loadingRankings.value = false;
    });
});

async function rowClick(id: any) {
  await navigateTo("/wrestler/" + id);
}
</script>
<template>
  <div>
    <ProgressSpinner v-if="loadingPlace" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-9/12">
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
      <Card class="w-9/12">
        <template #title> Rangliste </template>
        <template #content>
          <DataView :value="rankingsData" data-key="id">
            <template #list="slotProps">
              <div
                class="col-7 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.expand.wrestler.id)"
              >
                <div
                  class="flex flex-column sm:flex-row sm:align-items-start xl:flex-row xl:align-items-start"
                >
                  <div class="sm:w-4rem xl:w-4rem block mx-auto">
                    <p>{{ slotProps.data.rank }}</p>
                  </div>
                  <div class="sm:w-4rem xl:w-4rem block mx-auto">
                    <p>{{ slotProps.data.points }}</p>
                  </div>
                  <div class="sm:w-4rem xl:w-4rem block mx-auto">
                    <p>{{ slotProps.data.result }}</p>
                  </div>
                  <div class="sm:w-8rem xl:w-16rem block mx-auto">
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
