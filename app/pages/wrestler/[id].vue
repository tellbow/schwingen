<script setup lang="ts">
const pocketbase = usePocketbase();

const route = useRoute();

const wrestlerData = ref();
const rankingsData = ref();
const loadingWrestler = ref(true);
const loadingRankings = ref(true);

onMounted(async () => {
  await pocketbase
    .collection("wrestler")
    .getFirstListItem('id="' + route.params.id + '"', {
      expand: "club,club.canton,club.canton.association",
    })
    .then((data) => {
      data.year = data.year.split("-")[0];
      wrestlerData.value = data;
      loadingWrestler.value = false;
    });
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      filter: 'wrestler.id = "' + route.params.id + '"',
      expand: "place",
      sort: "-created",
    })
    .then((data) => {
      rankingsData.value = data;
      loadingRankings.value = false;
    });
});
</script>
<template>
  <div
    class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-5"
  >
    <ProgressSpinner v-if="loadingWrestler" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex flex-wrap fill-height"
    >
      <Avatar
        icon="pi pi-user"
        class="mr-2 mt-20"
        size="xlarge"
        shape="circle"
      />
      <Card>
        <template #title>
          {{ wrestlerData.vorname }} {{ wrestlerData.name }}
        </template>
        <template #content>
          <p>Nummer: {{ wrestlerData.nummer }}</p>
          <p>Kategorie: {{ wrestlerData.category }}</p>
          <p>Jahrgang: {{ wrestlerData.year }}</p>
          <p>Schwingklub: {{ wrestlerData.expand.club.name }}</p>
          <p>Gauverband: {{ wrestlerData.expand.club.expand.canton.name }}</p>
          <p>
            Schwingverband:
            {{ wrestlerData.expand.club.expand.canton.expand.association.name }}
            ({{
              wrestlerData.expand.club.expand.canton.expand.association
                .abbreviation
            }})
          </p>
        </template>
      </Card>
    </div>
    <ProgressSpinner v-if="loadingRankings" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex flex-wrap fill-height"
    >
      <DataView :value="rankingsData" data-key="id">
        <template #list="slotProps">
          <div class="col-7">
            <div
              class="flex flex-column xl:flex-row xl:align-items-start p-1 gap-4"
            >
              <div class="flex-1">
                <p>{{ slotProps.data.expand.place.name }}</p>
              </div>
              <div
                class="flex flex-column sm:flex-row justify-content-between align-items-center xl:align-items-start flex-1 gap-4"
              >
                <div
                  class="flex flex-column align-items-center sm:align-items-start gap-3"
                >
                  <p>{{ slotProps.data.rank }}</p>
                  <p>{{ slotProps.data.points }}</p>
                  <p>{{ slotProps.data.result }}</p>
                  <p>{{ route.params.id }}</p>
                </div>
              </div>
            </div>
          </div>
        </template>
      </DataView>
    </div>
  </div>
</template>
