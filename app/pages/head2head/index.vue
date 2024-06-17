<script setup lang="ts">
const pocketbase = usePocketbase();

const wrestlersData = ref();
const displayWrestler = (wrestlersData: { name: string; vorname: string }) =>
  wrestlersData.name + " " + wrestlersData.vorname;
const selectedWrestler = ref();
const selectedOpponent = ref();
const loadingWrestlers = ref(true);

onMounted(async () => {
  loadWrestlers();
});

const loadWrestlers = async () => {
  const customFilter = 'status != ""';
  await pocketbase
    .collection("wrestler")
    .getFullList(200 /* batch size */, {
      filter: customFilter,
      sort: "-status.symbol,name,-created",
      fields: "id,name,vorname",
    })
    .then((data) => {
      wrestlersData.value = data;
      loadingWrestlers.value = false;
    });
};

async function navigateHead2Head() {
  await navigateTo(
    "/head2head/" + selectedWrestler.value + "-" + selectedOpponent.value,
  );
}
</script>
<template>
  <div>
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title>1 vs. 1</template>
        <template #content>
          <Dropdown
            v-model="selectedWrestler"
            :options="wrestlersData"
            :option-label="displayWrestler"
            option-value="id"
            filter
            :filter-fields="['name', 'vorname']"
            :loading="loadingWrestlers"
            placeholder="Wähle einen Schwinger"
            empty-message="Keine Schwinger gefunden"
            class="m-1 w-full md:w-14rem"
          />
          <Dropdown
            v-model="selectedOpponent"
            :options="wrestlersData"
            :option-label="displayWrestler"
            option-value="id"
            filter
            :filter-fields="['name', 'vorname']"
            :loading="loadingWrestlers"
            placeholder="Wähle einen Gegner"
            empty-message="Keine Gegner gefunden"
            class="m-1 w-full md:w-14rem"
          />
          <Button
            type="button"
            label="Suchen"
            icon="pi pi-search"
            class="ml-2 mt-2 md:mt-0 bg-yellow-900 border-2 border-yellow-800"
            @click="navigateHead2Head()"
          />
        </template>
      </Card>
    </div>
  </div>
</template>
