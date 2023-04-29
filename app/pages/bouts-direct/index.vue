<script setup lang="ts">
const pocketbase = usePocketbase();

const loadingWrestlers = ref(true);
const loadingBouts = ref(false);
const selectedWrestler = ref();
const selectedOpponent = ref();
const wrestlers = ref();
const clashData = ref();

/* eslint require-await: "off" */
onMounted(async () => {
  loadingWrestlers.value = true;

  pocketbase
    .collection("wrestler")
    .getFullList(200 /* batch size */, {
      sort: "name,-created",
    })
    .then((data) => {
      wrestlers.value = data;
      loadingWrestlers.value = false;
    });
});

const findBouts = () => {
  loadingBouts.value = true;
  pocketbase
    .collection("bouts")
    .getFullList(200 /* batch size */, {
      filter:
        'wrestler.id = "' +
        selectedWrestler.value.id +
        '" && opponent.id = "' +
        selectedOpponent.value.id +
        '"',
      expand: "place",
      sort: "-created",
    })
    .then((data) => {
      data.forEach((item: { expand: any }) => {
        item.expand.place.year = item.expand.place.year.split("-")[0];
      });
      clashData.value = data;
      loadingBouts.value = false;
    });
};
</script>
<template>
  <div class="card">
    <Card class="mt-2">
      <template #title> Auswahl </template>
      <template #content>
        <div class="formgrid grid place-items-center">
          <div class="field col">
            <p>Schwinger:</p>
            <ProgressSpinner v-if="loadingWrestlers" />
            <!-- ToDo: FilterFields -->
            <Dropdown
              v-else
              v-model="selectedWrestler"
              :options="wrestlers"
              option-label="name"
              filter
              :filter-fields="['name', 'vorname']"
              placeholder="Wähle einen Schwinger"
              class="w-full md:w-14rem mt-1"
              :virtual-scroller-options="{
                itemSize: 40,
              }"
            >
              <template #value="slotProps">
                <div v-if="slotProps.value" class="flex align-items-center">
                  <div>
                    {{ slotProps.value.name }} {{ slotProps.value.vorname }}
                  </div>
                </div>
                <span v-else>
                  {{ slotProps.placeholder }}
                </span>
              </template>
              <template #option="slotProps">
                <div class="flex items-center">
                  <div>
                    {{ slotProps.option.name }} {{ slotProps.option.vorname }}
                  </div>
                </div>
              </template>
            </Dropdown>
          </div>
          <div class="field col text-center">
            <p class="font-bold text-xl xl:text-5xl lg:text-4xl md:text-3xl">
              vs.
            </p>
          </div>
          <div class="field col">
            <p class="mt-2">Gegner:</p>
            <ProgressSpinner v-if="loadingWrestlers" />
            <Dropdown
              v-else
              v-model="selectedOpponent"
              :options="wrestlers"
              option-label="name"
              filter
              :filter-fields="['name', 'vorname']"
              placeholder="Wähle einen Gegner"
              class="w-full md:w-14rem mt-1"
              :virtual-scroller-options="{
                itemSize: 40,
              }"
            >
              <template #value="slotProps">
                <div v-if="slotProps.value" class="flex align-items-center">
                  <div>
                    {{ slotProps.value.name }} {{ slotProps.value.vorname }}
                  </div>
                </div>
                <span v-else>
                  {{ slotProps.placeholder }}
                </span>
              </template>
              <template #option="slotProps">
                <div class="flex align-items-center">
                  <div>
                    {{ slotProps.option.name }} {{ slotProps.option.vorname }}
                  </div>
                </div>
              </template>
            </Dropdown>
          </div>
          <div class="field col">
            <Button
              type="button"
              label="Suchen"
              icon="pi pi-search"
              :loading="loadingBouts"
              @click="findBouts"
            />
          </div>
        </div>
      </template>
    </Card>
    <Card class="mt-2">
      <template #title> Ergebnis </template>
      <template #content>
        <p v-if="!clashData">
          Wähle einen Schwinger und einen Gegner aus und drücke dann auf
          <strong>Suchen</strong>.
        </p>
        <p v-else-if="Object.keys(clashData).length === 0">
          Keine Paarungen für diese Schwinger gefunden.
        </p>
        <DataView v-else :value="clashData" data-key="id">
          <template #list="slotProps">
            <div class="col-7 hover:bg-gray-200">
              <div
                class="flex flex-column xl:flex-row xl:align-items-start p-1 gap-4"
              >
                <div class="flex-1">
                  <p>
                    <strong> {{ slotProps.data.expand.place.name }}</strong>
                    {{ slotProps.data.expand.place.year }}
                  </p>
                </div>
                <div
                  class="flex flex-column sm:flex-row justify-content-between align-items-center xl:align-items-start flex-1 gap-4"
                >
                  <div
                    class="flex flex-column align-items-center sm:align-items-start"
                  >
                    <p>{{ slotProps.data.rank }}</p>
                    <p>{{ slotProps.data.points }}</p>
                    <p>{{ slotProps.data.result }}</p>
                  </div>
                </div>
              </div>
            </div>
          </template>
        </DataView>
      </template>
    </Card>
  </div>
</template>
