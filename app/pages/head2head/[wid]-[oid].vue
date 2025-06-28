<script setup lang="ts">
import Chart from "primevue/chart";
import { validateRouteParam } from "~/utils/filterUtils";

// Set SEO metadata for individual head2head pages
const setHead2HeadSEO = () => {
  if (statisticsData.value.length >= 2) {
    const wrestler1 = statisticsData.value[0];
    const wrestler2 = statisticsData.value[1];
    const wrestler1Name = `${wrestler1.vorname} ${wrestler1.name}`;
    const wrestler2Name = `${wrestler2.vorname} ${wrestler2.name}`;

    useSeo({
      title: `${wrestler1Name} vs ${wrestler2Name} - Head-to-Head - Tellbow`,
      description: `Vergleich zwischen ${wrestler1Name} und ${wrestler2Name}. Head-to-Head Statistiken, Durchschnittsrang, Punkte und Kränze im direkten Vergleich.`,
      keywords: `${wrestler1Name}, ${wrestler2Name}, Head-to-Head, Schwinger Vergleich, Schwingen, Schweizer Schwinger, ESV`,
      type: "article",
    });

    // Set structured data for the head2head comparison
    const { createAthlete, createBreadcrumbList, setStructuredData } =
      useStructuredData();
    const config = useRuntimeConfig();

    const athlete1Data = createAthlete({
      name: wrestler1Name,
      givenName: wrestler1.vorname,
      familyName: wrestler1.name,
      url: `${config.public.baseUrl}/wrestler/${wrestler1.id}`,
    });

    const athlete2Data = createAthlete({
      name: wrestler2Name,
      givenName: wrestler2.vorname,
      familyName: wrestler2.name,
      url: `${config.public.baseUrl}/wrestler/${wrestler2.id}`,
    });

    const breadcrumbs = createBreadcrumbList([
      { name: "Home", url: config.public.baseUrl },
      { name: "1 vs. 1 Vergleich", url: `${config.public.baseUrl}/head2head` },
      {
        name: `${wrestler1Name} vs ${wrestler2Name}`,
        url: `${config.public.baseUrl}/head2head/${wrestlerId.value}-${opponentId.value}`,
      },
    ]);

    setStructuredData([athlete1Data, athlete2Data, breadcrumbs]);
  } else {
    // Fallback SEO while loading
    useSeo({
      title: "Head-to-Head Vergleich - Tellbow",
      description:
        "Direkter Vergleich zwischen zwei Schweizer Schwingern. Statistiken und Analysen.",
      keywords:
        "Head-to-Head, Schwinger Vergleich, Schwingen, Schweizer Schwinger, ESV",
      type: "article",
    });
  }
};

// Types
interface Wrestler {
  id: string;
  name: string;
  vorname: string;
}

interface Place {
  id: string;
  name: string;
  year: string;
}

interface Expand {
  place: Place;
  wrestler: Wrestler;
  opponent: Wrestler;
}

interface DataEntry {
  id: string;
  expand: Expand;
  final: boolean;
  points: string;
  rank: string;
  rank2: string;
  result: string;
  status: string;
  wreath: boolean;
}

interface GroupedData {
  [key: string]: DataEntry[];
}

interface StatisticsData {
  id: string;
  name: string;
  vorname: string;
  averageRank: string;
  averagePoints: string;
  countWreaths: number;
  countFinals: number;
}

interface BoutsData {
  place: {
    id: string;
    name: string;
    year: string;
  };
  entries: Array<{
    id: string;
    points: string;
    result: string;
    wrestler: Wrestler;
    opponent: Wrestler;
  }>;
}

interface ChartData {
  datasets: Array<{
    label: string;
    data: Array<{
      x: number;
      y: number;
      r: number;
    }>;
    backgroundColor: string;
    borderColor: string;
  }>;
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

const opponentId = computed(() => {
  try {
    return validateRouteParam(route.params.oid);
  } catch (error) {
    console.error("Invalid opponent ID:", error);
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid opponent ID",
    });
  }
});

// Reactive state
const op = ref();
const statisticsData = ref<StatisticsData[]>([]);
const comparsionData = ref<ChartData | null>(null);
const boutsData = ref<BoutsData[]>([]);
const loadingStatistics = ref(true);
const loadingBouts = ref(true);

// Methods
const toggle = (event: Event): void => {
  op.value.toggle(event);
};

const loadStatisticsData = async (): Promise<void> => {
  try {
    const customFilter = `((wrestler.id = "${wrestlerId.value}") || (wrestler.id = "${opponentId.value}")) && (status != "Unfall" && points <= 60)`;

    const data = await pocketbase.collection("rankings").getFullList(200, {
      filter: customFilter,
      expand: "wrestler,place",
      sort: "-place.year,-created",
      fields:
        "id,rank,rank2,points,final,result,wreath,status,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.place.name,expand.place.year",
    });

    // Grouping data by wrestler name and vorname
    const groupedData: GroupedData = data.reduce(
      (acc: GroupedData, curr: DataEntry) => {
        if (!curr.expand) {
          return acc; // Skip this entry if wrestler or place is undefined
        }
        const { id, name, vorname } = curr.expand.wrestler;
        const key = `${id} ${name} ${vorname}`;
        if (!acc[key]) {
          acc[key] = [];
        }
        acc[key].push(curr);
        return acc;
      },
      {},
    );

    // Calculating statistics for each wrestler
    const statistics = Object.entries(groupedData).map(([key, value]) => {
      const [id, name, vorname] = key.split(" ");
      const validEntries = value.filter(({ result }) => result.length > 4);

      const averageRank =
        validEntries.length > 0
          ? (
              validEntries.reduce(
                (sum, entry) => sum + parseInt(entry.rank),
                0,
              ) / validEntries.length
            ).toFixed(2)
          : "0.00";

      const averagePoints =
        validEntries.length > 0
          ? (
              validEntries.reduce(
                (sum, entry) => sum + parseFloat(entry.points),
                0,
              ) / validEntries.length
            ).toFixed(2)
          : "0.00";

      const countWreaths = value.filter((entry) => entry.wreath).length;
      const countFinals = value.filter((entry) => entry.final).length;

      return {
        id,
        name,
        vorname,
        averageRank,
        averagePoints,
        countWreaths,
        countFinals,
      };
    });

    statisticsData.value = statistics;
    loadingStatistics.value = false;

    // Step 1: Group data by wrestler
    const groupedByWrestler: Record<string, any> = {};

    data.forEach((entry) => {
      if (entry.expand && entry.expand.wrestler) {
        const wrestler = entry.expand.wrestler;
        const fullName = `${wrestler.name} ${wrestler.vorname}`;
        if (!groupedByWrestler[fullName]) {
          groupedByWrestler[fullName] = {
            name: wrestler.name,
            vorname: wrestler.vorname,
            bubbles: [],
          };
        }
        groupedByWrestler[fullName].bubbles.push(entry);
      }
    });

    // Step 2: Process each wrestler's data
    const output = Object.values(groupedByWrestler).map((wrestler: any) => {
      const counts: Record<string, number> = {};

      wrestler.bubbles.forEach((entry: DataEntry) => {
        if (entry.result.length > 4) {
          const points = parseFloat(entry.points);
          const rank = parseInt(entry.rank);
          const key = `${points},${rank}`;
          counts[key] = (counts[key] || 0) + 1;
        }
      });

      wrestler.bubbles = Object.keys(counts).map((key) => {
        const [x, y] = key.split(",").map(Number);
        return { x, y, r: counts[key] };
      });

      return wrestler;
    });

    comparsionData.value = {
      datasets: [
        {
          label: `${output[0].name} ${output[0].vorname}`,
          data: output[0].bubbles,
          backgroundColor: "rgba(255, 99, 132, 0.5)",
          borderColor: "rgba(255, 99, 132, 0.9)",
        },
        {
          label: `${output[1].name} ${output[1].vorname}`,
          data: output[1].bubbles,
          backgroundColor: "rgba(0, 99, 132, 0.5)",
          borderColor: "rgba(0, 99, 132, 0.9)",
        },
      ],
    };

    setHead2HeadSEO();
  } catch (error) {
    console.error("Error loading statistics data:", error);
    loadingStatistics.value = false;
  }
};

const loadBoutsData = async (): Promise<void> => {
  try {
    const customFilter = `(wrestler.id = "${wrestlerId.value}" && opponent.id ~ "${opponentId.value}") || (wrestler.id = "${opponentId.value}" && opponent.id ~ "${wrestlerId.value}")`;

    const data = await pocketbase.collection("bouts").getFullList(200, {
      filter: customFilter,
      expand: "wrestler,opponent,place",
      sort: "-place.year,-wrestler.name,-created",
      fields:
        "id,result,points,fight_round,expand.wrestler.name,expand.wrestler.vorname,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name,expand.place.year",
    });

    const groupedData: Record<string, BoutsData> = {};
    data.forEach((entry) => {
      if (
        !entry.expand ||
        !entry.expand.place ||
        !entry.expand.wrestler ||
        !entry.expand.opponent
      ) {
        return;
      }
      const placeId = entry.expand.place.id;
      const placeName = entry.expand.place.name;
      const year = entry.expand.place.year.split("-")[0];
      const key = `${placeId}-${placeName}-${year}-${entry.fight_round}`;

      if (!groupedData[key]) {
        groupedData[key] = {
          place: {
            id: entry.expand.place.id,
            name: entry.expand.place.name,
            year: entry.expand.place.year.split("-")[0],
          },
          entries: [],
        };
      }
      groupedData[key].entries.push({
        id: entry.id,
        points: entry.points,
        result: entry.result,
        wrestler: entry.expand.wrestler,
        opponent: entry.expand.opponent,
      });
    });

    boutsData.value = Object.values(groupedData);
    loadingBouts.value = false;
  } catch (error) {
    console.error("Error loading bouts data:", error);
    loadingBouts.value = false;
  }
};

const isHigher = (stat: any, type: string, reverse = false): boolean => {
  if (!statisticsData.value.length) return false;

  // Find the entry with the highest value
  const highest = statisticsData.value.reduce(
    (acc: StatisticsData, curr: StatisticsData) => {
      return parseFloat(curr[type as keyof StatisticsData] as string) >
        parseFloat(acc[type as keyof StatisticsData] as string)
        ? curr
        : acc;
    },
  );

  // Compare current entry with the highest
  if (reverse) {
    return !(stat === highest[type as keyof StatisticsData]);
  }
  return stat === highest[type as keyof StatisticsData];
};

const chartOptions = ref({
  plugins: {
    legend: {
      position: "top",
    },
  },
  scales: {
    y: {
      reverse: true,
      title: {
        display: true,
        text: "Rang",
      },
    },
    x: {
      title: {
        display: true,
        text: "Punkte",
      },
    },
  },
  responsive: true,
});

const rowRClick = async (rid: string): Promise<void> => {
  try {
    await navigateTo(`/rankings/${rid}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

const rowWClick = async (wid: string): Promise<void> => {
  try {
    await navigateTo(`/wrestler/${wid}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

// Lifecycle
onMounted(async () => {
  await Promise.all([loadStatisticsData(), loadBoutsData()]);
});
</script>
<template>
  <div>
    <h1 class="sr-only">Direktvergleich Schwinger</h1>
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title>
          Statistiken
          <Badge value="?" @click="toggle" />
          <OverlayPanel ref="op"
            >Nur mit Ausstich, ohne eidgenössische Feste, ohne
            Unfälle</OverlayPanel
          >
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingStatistics" />
          <DataView
            v-else
            :value="statisticsData"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #empty>
              Keine Statistiken zu diesen Schwingern.
            </template>
            <template #header>
              <div class="grid mt-0">
                <p class="col md:col-5">Schwinger</p>
                <p class="col md:col">⌀ Rang</p>
                <p class="col md:col">⌀ Punkte</p>
                <p class="col md:col">Kränze</p>
                <p class="col md:col">Schlussgänge</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200"
                  @click="rowWClick(item.id)"
                >
                  <div class="grid">
                    <div class="col md:col-5">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col md:col">
                      <b v-if="isHigher(item.averageRank, 'averageRank', true)">
                        {{ item.averageRank }}
                      </b>
                      <p v-else>
                        {{ item.averageRank }}
                      </p>
                    </div>
                    <div class="col md:col">
                      <b v-if="isHigher(item.averagePoints, 'averagePoints')">
                        {{ item.averagePoints }}
                      </b>
                      <p v-else>
                        {{ item.averagePoints }}
                      </p>
                    </div>
                    <div class="col md:col">
                      <b v-if="isHigher(item.countWreaths, 'countWreaths')">
                        {{ item.countWreaths }}
                      </b>
                      <p v-else>
                        {{ item.countWreaths }}
                      </p>
                    </div>
                    <div class="col md:col">
                      <b v-if="isHigher(item.countFinals, 'countFinals')">
                        {{ item.countFinals }}
                      </b>
                      <p v-else>
                        {{ item.countFinals }}
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
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title> Aufeinandertreffen </template>
        <template #content>
          <ProgressSpinner v-if="loadingBouts" />
          <DataView
            v-else
            :value="boutsData"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #empty>
              Keine Aufeinandertreffen dieser Schwinger.
            </template>
            <template #header>
              <div class="grid mt-0">
                <p class="col md:col-7">Schwingfest (Jahr)</p>
                <p v-if="boutsData" class="col md:col text-center">
                  {{ boutsData[0].entries[0].wrestler.name }}
                  {{ boutsData[0].entries[0].wrestler.vorname }}
                </p>
                <p v-if="boutsData" class="col md:col text-center">
                  {{ boutsData[0].entries[1].wrestler.name }}
                  {{ boutsData[0].entries[1].wrestler.vorname }}
                </p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200"
                  @click="rowRClick(item.place.id)"
                >
                  <div class="grid">
                    <div class="col md:col-7">
                      <p>{{ item.place.name }} ({{ item.place.year }})</p>
                    </div>
                    <div class="col md:col text-center">
                      <div
                        v-if="item.entries[0].result === '+'"
                        class="flex justify-center"
                      >
                        <Icon name="mdi:crown" />
                        <b>{{ item.entries[0].points }}</b>
                      </div>
                      <p v-else>
                        {{ item.entries[0].points }}
                      </p>
                    </div>
                    <div class="col md:col text-center">
                      <div
                        v-if="item.entries[1].result === '+'"
                        class="flex justify-center"
                      >
                        <Icon name="mdi:crown" />
                        <b>{{ item.entries[1].points }}</b>
                      </div>
                      <p v-else>
                        {{ item.entries[1].points }}
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
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title>
          Graph
          <Badge value="?" @click="toggle" />
          <OverlayPanel ref="op"
            >Nur mit Ausstich, ohne eidgenössische Feste, ohne
            Unfälle</OverlayPanel
          >
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingBouts" />
          <Chart
            v-else
            type="bubble"
            :data="comparsionData"
            :options="chartOptions"
          />
        </template>
      </Card>
    </div>
  </div>
</template>
