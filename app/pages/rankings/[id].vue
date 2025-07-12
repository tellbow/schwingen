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

    // Set structured data for the sports event
    const { createEvent, createBreadcrumbList, setStructuredData } =
      useStructuredData();
    const config = useRuntimeConfig();

    const eventData = createEvent({
      name: `${placeName} ${placeYear}`,
      startDate: `${placeYear}-01-01`, // Approximate start date
      location: {
        name: placeLocation,
      },
      description: `${placeType} Schwingfest ${placeName} ${placeYear} in ${placeLocation}`,
      organizer: {
        name: "Eidgenössischer Schwingerverband",
        url: "https://esv.ch",
        description: "Schweizerischer Dachverband für Schwingen",
      },
    });

    const breadcrumbs = createBreadcrumbList([
      { name: "Home", url: config.public.baseUrl },
      { name: "Ranglisten", url: `${config.public.baseUrl}/rankings` },
      {
        name: `${placeName} ${placeYear}`,
        url: `${config.public.baseUrl}/rankings/${placeId.value}`,
      },
    ]);

    setStructuredData([eventData, breadcrumbs]);
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
  wstatusSymbol?: string;
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
          symbol: string;
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
          symbol: string;
        };
      };
    };
  };
}

// Composables
const pocketbase = usePocketbase();
const route = useRoute();
const { layout } = useLayout();

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
const activeTab = ref("0");

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
        "id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.wrestler.expand.status.status,expand.wrestler.expand.status.symbol",
    });

    data.forEach((entry: RankingData) => {
      if (
        !entry.expand ||
        !entry.expand.wrestler ||
        !entry.expand.wrestler.expand ||
        !entry.expand.wrestler.expand.status ||
        !entry.expand.wrestler.expand.status.status ||
        !entry.expand.wrestler.expand.status.symbol
      ) {
        entry.wstatus = "-";
        entry.wstatusSymbol = "-";
      } else {
        entry.wstatus = entry.expand.wrestler.expand.status.status;
        entry.wstatusSymbol = entry.expand.wrestler.expand.status.symbol;
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

const loadAllBoutsData = async (): Promise<void> => {
  try {
    loadingBouts.value = true;

    // Load bouts for all wrestlers in this place
    const boutsData = await pocketbase.collection("bouts").getFullList(1000, {
      expand: "opponent,opponent.status",
      filter: `place.id = '${escapeFilterValue(placeId.value)}'`,
      sort: "wrestler.name,fight_round,-created",
      fields:
        "id,result,points,fight_round,wrestler,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.opponent.expand.status.status,expand.opponent.expand.status.symbol",
    });

    // Group bouts by wrestler
    const boutsByWrestler = new Map<string, BoutData[]>();

    for (const bout of boutsData) {
      const wrestlerId = bout.wrestler;
      if (!boutsByWrestler.has(wrestlerId)) {
        boutsByWrestler.set(wrestlerId, []);
      }
      boutsByWrestler.get(wrestlerId)?.push(bout as unknown as BoutData);
    }

    // Add bouts to rankings data
    rankingsData.value.forEach((ranking) => {
      const wrestlerBouts =
        boutsByWrestler.get(ranking.expand.wrestler.id) || [];
      ranking.bouts = wrestlerBouts;
    });
  } catch (error) {
    console.error("Error loading all bouts data:", error);
  } finally {
    loadingBouts.value = false;
  }
};

// Lifecycle
onMounted(async () => {
  try {
    await Promise.all([loadPlaceData(), loadRankingsData()]);
    await loadAllBoutsData();
  } catch (error) {
    console.error("Error in component mount:", error);
  }
});
</script>
<template>
  <div>
    <h1 class="sr-only">Rangliste Detail</h1>
    <ProgressSpinner v-if="loadingPlace" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title> Schwingfest: {{ placeData?.name }} </template>
        <template #content>
          <p>Ort: {{ placeData?.location }}</p>
          <p>Jahr: {{ placeData?.year }}</p>
          <p v-if="placeData?.expand?.placeType">
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
        <template #title> Resultate</template>
        <template #content>
          <div class="tabs-container">
            <div class="tab-header">
              <button
                :class="['tab-button', { active: activeTab === '0' }]"
                @click="activeTab = '0'"
              >
                Rangliste
              </button>
              <button
                :class="['tab-button', { active: activeTab === '1' }]"
                @click="activeTab = '1'"
              >
                Statistiken
              </button>
            </div>
            <div class="tab-content">
              <div v-if="activeTab === '0'" class="tab-panel">
                <!-- Desktop/Landscape Layout -->
                <DataTable
                  v-if="layout === 'default'"
                  :value="rankingsData"
                  column-resize-mode="fit"
                  show-gridlines
                  class="table-style-default"
                  size="small"
                  data-key="id"
                  :pt="{
                    header: { class: 'p-0' },
                  }"
                  :row-hover="true"
                >
                  <template #empty> Keine Ranglisten gefunden. </template>
                  <template #loading>
                    Ranglisten werden geladen. Bitte warten.
                  </template>
                  <Column
                    field="rank"
                    header="Rang"
                    class="table-column-small"
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
                    class="table-column-small"
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
                    class="table-column-small"
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
                    class="table-column-small"
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
                    class="table-column-small"
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
                    class="table-column-small"
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
                    field="wreath"
                    header="Kranz"
                    class="table-column-small"
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
                    </template>
                  </Column>
                  <Column
                    field="accident"
                    header="Unfall"
                    class="table-column-small"
                    :pt="{
                      filterInput: { class: 'w-fit' },
                    }"
                  >
                    <template #body="{ data }">
                      <Icon
                        v-if="data.status === 'Unfall'"
                        class="flex content-center"
                        name="game-icons:arm-bandage"
                      />
                    </template>
                  </Column>
                </DataTable>

                <!-- Mobile Layout -->
                <div v-else class="mobile-rankings">
                  <div
                    v-for="ranking in rankingsData"
                    :key="ranking.id"
                    class="mobile-ranking-card"
                  >
                    <div class="ranking-header">
                      <div class="rank-badge">
                        {{ ranking.rank }}{{ ranking.rank2 }}
                      </div>
                      <div class="wrestler-info">
                        <div class="wrestler-name">
                          {{ ranking.expand.wrestler.name }}
                          {{ ranking.expand.wrestler.vorname }}
                        </div>
                        <div class="wrestler-status">
                          <span
                            v-if="
                              ranking.wstatusSymbol &&
                              ranking.wstatusSymbol !== '-'
                            "
                            class="status-symbol"
                          >
                            {{ ranking.wstatusSymbol }}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div class="ranking-details">
                      <div class="detail-item">
                        <span class="detail-label">Punkte:</span>
                        <span class="detail-value">{{ ranking.points }}</span>
                      </div>
                      <div class="detail-item">
                        <span class="detail-label">Resultat:</span>
                        <span class="detail-value">{{ ranking.result }}</span>
                      </div>
                    </div>
                    <div class="ranking-icons">
                      <span
                        v-if="ranking.final"
                        class="final-badge"
                        title="Schlussgang"
                      >
                        Schlussgang
                      </span>
                      <Icon
                        v-if="ranking.wreath"
                        class="ranking-icon"
                        name="mingcute:wreath-fill"
                        title="Kranz"
                      />
                      <Icon
                        v-if="ranking.status === 'Unfall'"
                        class="ranking-icon"
                        name="game-icons:arm-bandage"
                        title="Unfall"
                      />
                    </div>
                  </div>
                </div>
              </div>

              <div v-if="activeTab === '1'" class="tab-panel">
                <ProgressSpinner v-if="loadingBouts" />
                <div v-else class="stats-grid">
                  <div
                    v-for="ranking in rankingsData"
                    :key="ranking.id"
                    class="stats-card"
                  >
                    <div class="stats-header">
                      <div class="wrestler-name">
                        {{ ranking.rank }}{{ ranking.rank2 }}.
                        {{ ranking.expand.wrestler.name }}
                        {{ ranking.expand.wrestler.vorname }}
                        <span
                          v-if="ranking.expand.wrestler.expand.status?.symbol"
                          class="status-symbol"
                        >
                          {{ ranking.expand.wrestler.expand.status?.symbol }}
                        </span>
                      </div>
                      <div class="wrestler-info">
                        {{ ranking.points }} Punkte
                      </div>
                    </div>
                    <div class="stats-table-container">
                      <table class="stats-table">
                        <thead>
                          <tr>
                            <th>Resultat</th>
                            <th>Gegner</th>
                            <th>Punkte</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr v-for="bout in ranking.bouts" :key="bout.id">
                            <td>{{ bout.result }}</td>
                            <td>
                              {{ bout.expand.opponent.name }}
                              {{ bout.expand.opponent.vorname }}
                              <span
                                v-if="
                                  bout.expand.opponent.expand.status?.symbol
                                "
                                class="status-symbol"
                              >
                                {{ bout.expand.opponent.expand.status?.symbol }}
                              </span>
                            </td>
                            <td>{{ bout.points }}</td>
                          </tr>
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>
      </Card>
    </div>
  </div>
</template>
<style scoped>
.tabs-container {
  width: 100%;
}

.tab-header {
  display: flex;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 1rem;
}

.tab-button {
  padding: 0.75rem 1.5rem;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  color: #6b7280;
  border-bottom: 2px solid transparent;
  transition: all 0.2s ease;
}

.tab-button:hover {
  color: #374151;
  background-color: #f9fafb;
}

.tab-button.active {
  color: #1f2937;
  border-bottom-color: #f59e0b;
  font-weight: 600;
}

.tab-content {
  min-height: 200px;
}

.tab-panel {
  animation: fadeIn 0.3s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Statistics Grid Styles */
.stats-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
  justify-items: center;
}

@media (min-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    justify-items: stretch;
  }
}

@media (min-width: 1024px) {
  .stats-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

.stats-card {
  width: 100%;
  max-width: 400px;
  padding: 0.25rem;
  height: 300px;
  display: flex;
  flex-direction: column;
}

.stats-header {
  margin-bottom: 0.5rem;
  flex-shrink: 0;
}

.wrestler-name {
  font-weight: 600;
  font-size: 1.125rem;
  color: #1f2937;
  margin-bottom: 0.25rem;
}

.wrestler-info {
  font-size: 0.875rem;
  color: #6b7280;
}

.stats-table-container {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.stats-table {
  width: 100%;
  font-size: 0.75rem;
  border-collapse: collapse;
  flex: 1;
}

.stats-table thead {
  background-color: #f3f4f6;
  border-bottom: 1px solid #e5e7eb;
}

.stats-table th {
  padding: 0.25rem;
  text-align: left;
  font-weight: 600;
  color: #374151;
}

.stats-table tbody {
  overflow-y: auto;
}

.stats-table td {
  padding: 0.25rem;
  border-bottom: 1px solid #f3f4f6;
  color: #374151;
}

.stats-table tr:hover {
  background-color: #f9fafb;
}

/* Mobile Rankings Styles */
.mobile-rankings {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.mobile-ranking-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  padding: 0.75rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.ranking-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.rank-badge {
  background: #f59e0b;
  color: white;
  font-weight: 600;
  font-size: 1.125rem;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  min-width: 2.5rem;
  text-align: center;
}

.wrestler-info {
  flex: 1;
}

.wrestler-name {
  font-weight: 600;
  font-size: 1rem;
  color: #1f2937;
  margin-bottom: 0.25rem;
}

.wrestler-status {
  font-size: 0.875rem;
  color: #6b7280;
}

.ranking-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.detail-label {
  font-size: 0.875rem;
  color: #6b7280;
  font-weight: 500;
}

.detail-value {
  font-size: 0.875rem;
  color: #1f2937;
  font-weight: 600;
}

.ranking-icons {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
  align-items: center;
}

.ranking-icon {
  width: 1.25rem;
  height: 1.25rem;
  color: #6b7280;
}

.final-badge {
  background: #f59e0b;
  color: white;
  font-size: 0.75rem;
  font-weight: 600;
  padding: 0.25rem 0.5rem;
  border-radius: 0.25rem;
  text-transform: uppercase;
}

.final-text {
  color: #f59e0b;
  font-weight: 600;
  font-size: 0.875rem;
}

.status-symbol {
  font-size: 0.75rem;
  color: #6b7280;
  margin-left: 0.25rem;
}
</style>
