<script setup lang="ts">
import { validateRouteParam } from "~/utils/filterUtils";

// Types
interface OpponentData {
  id: string;
  name: string;
  vorname: string;
}

interface BoutData {
  id: string;
  fight_round: string;
  result: string;
  points: string;
  expand: {
    wrestler: OpponentData;
    opponent: OpponentData;
    place: {
      id: string;
      name: string;
    };
  };
}

// Composables
const pocketbase = usePocketbase();
const route = useRoute();

// Validate route parameters
const wrestlerId = computed(() => {
  try {
    return validateRouteParam(route.params.wid);
  } catch (error) {
    console.error("Invalid wrestler ID:", error);
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid wrestler ID",
    });
  }
});

const placeId = computed(() => {
  try {
    return validateRouteParam(route.params.pid);
  } catch (error) {
    console.error("Invalid place ID:", error);
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid place ID",
    });
  }
});

// Reactive state
const opponentsData = ref<BoutData[]>([]);
const loadingOpponents = ref(true);

// Methods
const loadBoutsData = async (): Promise<void> => {
  try {
    const data = await pocketbase.collection("bouts").getFullList(10, {
      filter: `wrestler.id = "${wrestlerId.value}" && place.id = "${placeId.value}"`,
      expand: "wrestler,opponent,place",
      sort: "fight_round,-created",
      fields:
        "id,fight_round,result,points,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name",
    });

    opponentsData.value = data;
  } catch (error) {
    console.error("Error loading bouts data:", error);
    opponentsData.value = [];
  } finally {
    loadingOpponents.value = false;
  }
};

const rowClick = async (wid: string, pid: string): Promise<void> => {
  try {
    await navigateTo(`/wrestler/${wid}-${pid}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

// Lifecycle
onMounted(async () => {
  await loadBoutsData();
});
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
          <div v-if="opponentsData.length > 0">
            {{ opponentsData[0].expand.place.name }} -
            {{ opponentsData[0].expand.wrestler.name }}
            {{ opponentsData[0].expand.wrestler.vorname }}
          </div>
          <div v-else>Keine Daten verfügbar</div>
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
                      <span>{{ item.fight_round }}</span>
                    </div>
                    <div class="col-2">
                      <span>{{ item.result }}</span>
                    </div>
                    <div class="col-3">
                      <span>{{ item.points }}</span>
                    </div>
                    <div class="col-6">
                      <span>
                        {{ item.expand.opponent.name }}
                        {{ item.expand.opponent.vorname }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </template>
            <template #empty>
              <div class="text-center py-4">
                <p>Keine Kämpfe gefunden.</p>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
    </div>
  </div>
</template>
