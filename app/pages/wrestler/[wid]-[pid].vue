<script setup lang="ts">
const pocketbase = usePocketbase();

const route = useRoute();

const opponentsData = ref();
const loadingOpponents = ref(true);

onMounted(async () => {
  await pocketbase
    .collection("bouts")
    .getFullList(10 /* batch size */, {
      filter:
        'wrestler.id = "' +
        route.params.wid +
        '" && place.id = "' +
        route.params.pid +
        '"',
      expand: "wrestler,opponent,place",
      sort: "fight_round,-created",
      fields:
        "id,fight_round,result,points,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name",
    })
    .then((data) => {
      opponentsData.value = data;
      loadingOpponents.value = false;
    });
});

async function rowClick(wid: any, pid: any) {
  await navigateTo("/wrestler/" + wid + "-" + pid);
}
</script>
<template>
  <div>
    <ProgressSpinner v-if="loadingOpponents" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title>
          {{ opponentsData[0].expand.place.name }} -
          {{ opponentsData[0].expand.wrestler.name }}
          {{ opponentsData[0].expand.wrestler.vorname }}
        </template>
        <template #content>
          <DataView :value="opponentsData" data-key="id">
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="
                    rowClick(item.expand.opponent.id, item.expand.place.id)
                  "
                >
                  <div class="grid">
                    <div class="col-1">
                      <p>{{ item.fight_round }}</p>
                    </div>
                    <div class="col-2">
                      <p>{{ item.result }}</p>
                    </div>
                    <div class="col-3">
                      <p>{{ item.points }}</p>
                    </div>
                    <div class="col-6">
                      <p>
                        {{ item.expand.opponent.name }}
                        {{ item.expand.opponent.vorname }}
                      </p>
                    </div>
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
