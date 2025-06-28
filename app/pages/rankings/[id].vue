<script setup lang="ts">
import { validateRouteParam, escapeFilterValue } from "~/utils/filterUtils";

// Set SEO metadata for individual ranking pages
const setRankingSEO = () => {
  if (placeData.value) {
    const placeName = placeData.value.name;
    const placeLocation = placeData.value.location;
    const placeYear = placeData.value.year;
    const placeType = placeData.value.expand?.placeType?.type || "";

    useSeo({
      title: `${placeName} ${placeYear} - Rangliste - Tellbow`,
      description: `Rangliste und Ergebnisse des ${placeType} ${placeName} ${placeYear} in ${placeLocation}. Alle Schwinger, Punkte und Kränze.`,
      keywords: `${placeName}, ${placeLocation}, ${placeYear}, ${placeType}, Rangliste, Schwingen, Schweizer Schwinger, ESV`,
      type: "article",
    });
  } else {
    // Fallback SEO while loading
    useSeo({
      title: "Rangliste - Tellbow",
      description: "Rangliste und Ergebnisse von Schweizer Schwingern.",
      keywords: "Rangliste, Schwingen, Schweizer Schwinger, ESV",
      type: "article",
    });
  }
};

// Types
interface PlaceData {
  id: string;
  name: string;
  location: string;
  year: string;
  expand: {
    placeType: {
      type: string;
    };
  };
}

interface RankingData {
  id: string;
  rank: string;
  rank2: string;
  points: string;
  final: boolean;
  result: string;
  wreath: boolean;
  status: string;
  wstatus?: string;
  bouts?: BoutData[];
  expand: {
    place: {
      id: string;
    };
    wrestler: {
      id: string;
      name: string;
      vorname: string;
      expand: {
        status: {
          status: string;
        };
      };
    };
  };
}

interface BoutData {
  id: string;
  result: string;
  points: string;
  fight_round: string;
  expand: {
    opponent: {
      id: string;
      name: string;
      vorname: string;
      expand: {
        status: {
          status: string;
        };
      };
    };
  };
}

interface RowExpandEvent {
  data: RankingData;
}

interface RowCollapseEvent {
  data: {
    id: string;
  };
}

// Composables
const pocketbase = usePocketbase();
const route = useRoute();

// Validate route parameter
const placeId = computed(() => {
  try {
    return validateRouteParam(route.params.id);
  } catch (error) {
    console.error("Invalid place ID:", error);
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid place ID",
    });
  }
});

// Reactive state
const placeData = ref<PlaceData | null>(null);
const rankingsData = ref<RankingData[]>([]);
const loadingPlace = ref(true);
const loadingRankings = ref(true);
const loadingBouts = ref(true);
const expandedRows = ref();

// Methods
const loadPlaceData = async (): Promise<void> => {
  try {
    const data = await pocketbase
      .collection("places")
      .getFirstListItem(`id="${placeId.value}"`, { expand: "placeType" });

    data.year = data.year.split("-")[0];
    placeData.value = data;
    setRankingSEO();
  } catch (error) {
    console.error("Error loading place data:", error);
    throw createError({
      statusCode: 404,
      statusMessage: "Place not found",
    });
  } finally {
    loadingPlace.value = false;
  }
};

const loadRankingsData = async (): Promise<void> => {
  try {
    const data = await pocketbase.collection("rankings").getFullList(200, {
      filter: `place.id = "${placeId.value}"`,
      expand: "place,wrestler,wrestler.status",
      sort: "rank, rank2, -created",
      fields:
        "id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.wrestler.expand.status.status",
    });

    data.forEach((entry: RankingData) => {
      if (
        !entry.expand ||
        !entry.expand.wrestler ||
        !entry.expand.wrestler.expand ||
        !entry.expand.wrestler.expand.status ||
        !entry.expand.wrestler.expand.status.status
      ) {
        entry.wstatus = "-";
      } else {
        entry.wstatus = entry.expand.wrestler.expand.status.status;
      }
    });

    rankingsData.value = data.sort(compareByRank);
  } catch (error) {
    console.error("Error loading rankings data:", error);
    rankingsData.value = [];
  } finally {
    loadingRankings.value = false;
  }
};

const loadLazySubData = async (
  wrestlerId: string,
  placeId: string,
): Promise<void> => {
  try {
    loadingBouts.value = true;

    const data = await pocketbase.collection("bouts").getList(1, 10, {
      expand: "opponent,opponent.status",
      filter: `wrestler.id = '${escapeFilterValue(wrestlerId)}' && place.id = '${escapeFilterValue(placeId)}'`,
      sort: "fight_round,-created",
      fields:
        "id,result,points,fight_round,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.opponent.expand.status.status",
    });

    rankingsData.value.forEach((item: RankingData) => {
      if (
        item.expand.wrestler.id === wrestlerId &&
        item.expand.place.id === placeId
      ) {
        item.bouts = data.items;
      }
    });
  } catch (error) {
    console.error("Error loading sub data:", error);
  } finally {
    loadingBouts.value = false;
  }
};

// Custom comparator function to sort by rank
const compareByRank = (a: RankingData, b: RankingData): number => {
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

const onRowExpand = (event: RowExpandEvent): void => {
  const { wrestler } = event.data.expand;
  loadLazySubData(wrestler.id, placeId.value);
};

const onRowCollapse = (event: RowCollapseEvent): void => {
  const objIndex = rankingsData.value.findIndex(
    (obj: RankingData) => obj.id === event.data.id,
  );
  if (objIndex !== -1) {
    rankingsData.value[objIndex].bouts = [];
  }
};

// Lifecycle
onMounted(async () => {
  try {
    await Promise.all([loadPlaceData(), loadRankingsData()]);
  } catch (error) {
    console.error("Error in component mount:", error);
  }
});
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
        <template #title> Rangliste</template>
        <template #content>
          <DataTable
            v-model:expanded-rows="expandedRows"
            :value="rankingsData"
            column-resize-mode="fit"
            show-gridlines
            table-style="min-width: 50rem"
            size="small"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
            :row-hover="true"
            @row-expand="onRowExpand($event)"
            @row-collapse="onRowCollapse($event)"
          >
            <template #empty> Keine Ranglisten gefunden. </template>
            <template #loading>
              Ranglisten werden geladen. Bitte warten.
            </template>
            <Column expander style="width: 4rem" />
            <Column
              field="rank"
              header="Rang"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.rank }}{{ data.rank2 }}
              </template>
            </Column>
            <Column
              field="points"
              header="Punkte"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.points }}
              </template>
            </Column>
            <Column
              field="result"
              header="Resultat"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.result }}
              </template>
            </Column>
            <Column
              field="wrestler"
              header="Schwinger"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.expand.wrestler.name }}
                {{ data.expand.wrestler.vorname }}
              </template>
            </Column>
            <Column
              field="status"
              header="Status"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                {{ data.wstatus }}
              </template>
            </Column>
            <Column
              field="final"
              header="Schlussgang"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                <Icon
                  v-if="data.final"
                  class="flex content-center"
                  name="gis:flag-finish"
                />
              </template>
            </Column>
            <Column
              field="wreath_accident"
              header="Kranz / Unfall"
              style="min-width: 6rem; padding: 0.5rem"
              :pt="{
                filterInput: { class: 'w-fit' },
              }"
            >
              <template #body="{ data }">
                <Icon
                  v-if="data.wreath"
                  class="flex content-center"
                  name="mingcute:wreath-fill"
                />
                <Icon
                  v-if="data.status === 'Unfall'"
                  class="flex content-center"
                  name="game-icons:arm-bandage"
                />
              </template>
            </Column>
            <template #expansion="data">
              <div class="p-1">
                <DataTable :value="data.data.bouts">
                  <Column field="result" header="R" />
                  <Column field="points" header="P" />
                  <Column field="fight_round" header="G" />
                  <Column field="expand.opponent.name" header="Name" />
                  <Column field="expand.opponent.vorname" header="Vorname" />
                  <Column
                    field="expand.opponent.expand.status.status"
                    header="Status"
                  />
                </DataTable>
              </div>
            </template>
          </DataTable>
        </template>
      </Card>
    </div>
  </div>
</template>
