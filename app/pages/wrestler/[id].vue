<script setup lang="ts">
import Chart from "primevue/chart";
import { validateRouteParam } from "~/utils/filterUtils";

// Set SEO metadata for individual wrestler pages
const setWrestlerSEO = () => {
  if (wrestlerData.value) {
    const fullName = `${wrestlerData.value.vorname} ${wrestlerData.value.name}`;
    const clubName = wrestlerData.value.expand?.club?.name || "";
    const cantonName =
      wrestlerData.value.expand?.club?.expand?.canton?.name || "";
    const associationName =
      wrestlerData.value.expand?.club?.expand?.canton?.expand?.association
        ?.name || "";

    useSeo({
      title: `${fullName} - Tellbow`,
      description: `Profil und Statistiken von ${fullName}${clubName ? ` (${clubName})` : ""}. Ranglisten, ELO-Rating, Kränze und detaillierte Analysen aus der ESV-Datenbank.`,
      keywords: `${fullName}, Schwinger, ESV, Schwingen, Statistiken, ${clubName}, ${cantonName}, ${associationName}`,
      type: "profile",
    });

    // Set structured data for the wrestler
    const { createAthlete, createBreadcrumbList, setStructuredData } =
      useStructuredData();
    const config = useRuntimeConfig();

    const athleteData = createAthlete({
      name: fullName,
      givenName: wrestlerData.value.vorname,
      familyName: wrestlerData.value.name,
      url: `${config.public.baseUrl}/wrestler/${wrestlerData.value.id}`,
      ...(clubName && {
        worksFor: {
          name: clubName,
          url: `${config.public.baseUrl}/associations/club/${wrestlerData.value.expand?.club?.id}`,
          description: `Schwingclub ${clubName}`,
        },
      }),
    });

    const breadcrumbs = createBreadcrumbList([
      { name: "Home", url: config.public.baseUrl },
      { name: "Schwinger", url: `${config.public.baseUrl}/wrestler` },
      {
        name: fullName,
        url: `${config.public.baseUrl}/wrestler/${wrestlerData.value.id}`,
      },
    ]);

    setStructuredData([athleteData, breadcrumbs]);
  } else {
    // Fallback SEO while loading
    useSeo({
      title: "Schwinger - Tellbow",
      description: "Schwinger Profil und Statistiken aus der ESV-Datenbank.",
      keywords: "Schwinger, ESV, Schwingen, Statistiken",
      type: "profile",
    });
  }
};

// Types
interface WrestlerData {
  id: string;
  name: string;
  vorname: string;
  year: string;
  category?: string;
  expand?: {
    status?: {
      status: string;
    };
    club?: {
      name: string;
      expand?: {
        canton?: {
          name: string;
          expand?: {
            association?: {
              name: string;
              abbreviation: string;
            };
          };
        };
      };
    };
    metadata?: {
      website?: string;
      instagram?: string;
    };
  };
}

interface EloData {
  id: string;
  rating: string | number;
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
  expand: {
    place: {
      id: string;
      name: string;
      year: string;
      originalDate?: string;
      expand: {
        placeType: {
          type: string;
        };
      };
    };
  };
}

interface OpponentData {
  id: string;
  name: string;
  vorname: string;
}

interface TopOpponentData {
  id: string;
  name: string;
  vorname: string;
  count: number;
}

interface BoutData {
  id: string;
  result: string;
  points: string;
  expand: {
    place: {
      id: string;
      name: string;
      year: string;
    };
  };
}

interface YearOption {
  year: string | number;
}

interface ChartData {
  labels: string[];
  datasets: Array<{
    data: number[];
    backgroundColor: string[];
    hoverBackgroundColor: string[];
  }>;
}

interface GraphData {
  labels: string[];
  datasets: Array<{
    label: string;
    data: Array<{
      winPercentage?: number;
      drawPercentage?: number;
      lossPercentage?: number;
      win?: number;
      draw?: number;
      loss?: number;
    }>;
    parsing: {
      xAxisKey: string;
      yAxisKey: string;
    };
    backgroundColor: string[];
    hoverBackgroundColor: string[];
  }>;
}

// Composables
const pocketbase = usePocketbase();
const route = useRoute();
const { layout } = useLayout();

// Validate route parameter
const wrestlerId = computed(() => {
  try {
    return validateRouteParam(route.params.id);
  } catch (error) {
    console.error("Invalid wrestler ID:", error);
    throw createError({
      statusCode: 400,
      statusMessage: "Invalid wrestler ID",
    });
  }
});

// Reactive state
const wrestlerData = ref<WrestlerData | null>(null);
const eloData = ref<EloData | null>(null);
const rankingsData = ref<RankingData[]>([]);
const opponentsData = ref<OpponentData[]>([]);
const selectedOpponent = ref<string | null>(null);
const topOpponentsData = ref<TopOpponentData[]>([]);
const boutsData = ref<BoutData[]>([]);

// Wreath counters
const wreath1 = ref(0);
const wreath2 = ref(0);
const wreath3 = ref(0);

// Chart data
const ratioWinDrawLoss = ref<ChartData | null>(null);
const graphWinDrawLoss = ref<GraphData | null>(null);

// Loading states
const loadingWrestler = ref(true);
const loadingRankings = ref(true);
const loadingOpponents = ref(true);
const loadingTopOpponents = ref(true);
const loadingBouts = ref(false);

// Year selection
const selectedYear = ref<YearOption>({ year: "Alle" });
const years: YearOption[] = [
  { year: 2015 },
  { year: 2016 },
  { year: 2017 },
  { year: 2018 },
  { year: 2019 },
  { year: 2020 },
  { year: 2021 },
  { year: 2022 },
  { year: 2023 },
  { year: 2024 },
  { year: 2025 },
  { year: "Alle" },
];

// Computed properties
const averageRank = computed(() => {
  if (!rankingsData.value.length) return "-";

  const totalRank = rankingsData.value
    .map((item) => parseInt(item.rank.replace(/\D/g, "")) || 0)
    .reduce((sum, rank) => sum + rank, 0);

  const average = totalRank / rankingsData.value.length;
  return isNaN(average) ? "-" : average.toFixed(2);
});

const averagePoints = computed(() => {
  if (!rankingsData.value.length) return "-";

  const totalPoints = rankingsData.value
    .map((item) => parseInt(item.points) || 0)
    .reduce((sum, points) => sum + points, 0);

  const average = totalPoints / rankingsData.value.length;
  return isNaN(average) ? "-" : average.toFixed(2);
});

// Methods
const displayOpponent = (opponent: OpponentData): string => {
  return `${opponent.name} ${opponent.vorname}`;
};

const loadWrestlerData = async (): Promise<void> => {
  try {
    const data = await pocketbase
      .collection("wrestler")
      .getFirstListItem(`id="${wrestlerId.value}"`, {
        expand: "status,metadata,club,club.canton,club.canton.association",
        fields:
          "id,name,vorname,year,category,expand.status.status,expand.metadata.website,expand.metadata.instagram,expand.club.name,expand.club.expand.canton.name,expand.club.expand.canton.expand.association.name,expand.club.expand.canton.expand.association.abbreviation",
      });

    data.year = data.year ? data.year.split("-")[0] : "-";
    wrestlerData.value = data as unknown as WrestlerData;
    setWrestlerSEO();
  } catch (error) {
    console.error("Error loading wrestler data:", error);
    throw error;
  }
};

const loadEloData = async (): Promise<void> => {
  try {
    if (selectedYear.value.year === "Alle") {
      // Try years in descending order (most recent first, skipping 'Alle')
      const sortedYears = years
        .map((y) => y.year)
        .filter((y) => y !== "Alle")
        .sort((a, b) => Number(b) - Number(a));
      let found = false;
      for (const y of sortedYears) {
        try {
          const data = await pocketbase
            .collection(`elo${y}`)
            .getFirstListItem(`wrestler.id="${wrestlerId.value}"`, {
              fields: "id,rating",
            });
          eloData.value = data as unknown as EloData;
          found = true;
          break;
        } catch (error) {
          console.error("Error loading most recent year:", error);
        }
      }
      if (!found) {
        eloData.value = { id: "", rating: "-" };
      }
    } else {
      try {
        const data = await pocketbase
          .collection(`elo${selectedYear.value.year}`)
          .getFirstListItem(`wrestler.id="${wrestlerId.value}"`, {
            fields: "id,rating",
          });
        eloData.value = data as unknown as EloData;
      } catch (error) {
        console.error("Error loading ELO data:", error);
        eloData.value = { id: "", rating: "-" };
      }
    }
  } catch (error) {
    console.error("Error loading ELO data:", error);
    eloData.value = { id: "", rating: "-" };
  }
};

const loadBoutsData = async (): Promise<void> => {
  try {
    const customFilter =
      selectedYear.value.year === "Alle"
        ? `wrestler.id = "${wrestlerId.value}"`
        : `wrestler.id = "${wrestlerId.value}" && place.year ~ "${selectedYear.value.year}"`;

    const data = await pocketbase.collection("bouts").getFullList(200, {
      filter: customFilter,
      expand: "opponent",
      sort: "opponent.name,-created",
      fields:
        "id,expand.opponent.id,expand.opponent.name,expand.opponent.vorname",
    });

    // Deduplicate opponents
    const opponentMap = new Map<string, OpponentData>();
    data.forEach((obj: any) => {
      const opponent = obj.expand.opponent;
      opponentMap.set(opponent.id, {
        id: opponent.id,
        name: opponent.name,
        vorname: opponent.vorname,
      });
    });

    opponentsData.value = Array.from(opponentMap.values());
  } catch (error) {
    console.error("Error loading bouts data:", error);
    opponentsData.value = [];
  } finally {
    loadingOpponents.value = false;
  }
};

const loadRankingsData = async (): Promise<void> => {
  try {
    const customFilter =
      selectedYear.value.year === "Alle"
        ? `wrestler.id = "${wrestlerId.value}"`
        : `wrestler.id = "${wrestlerId.value}" && place.year ~ "${selectedYear.value.year}"`;

    const data = await pocketbase.collection("rankings").getFullList(200, {
      filter: customFilter,
      expand: "place,place.placeType",
      sort: "-place.year,-created",
      fields:
        "id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.place.name,expand.place.year,expand.place.expand.placeType.type",
    });

    // Reset wreath counters
    wreath1.value = 0;
    wreath2.value = 0;
    wreath3.value = 0;

    data.forEach((item: any) => {
      if (item.wreath) {
        const placeType = item.expand?.place?.expand?.placeType?.type;
        switch (placeType) {
          case "Gauverband":
          case "Kantonal":
            wreath1.value++;
            break;
          case "Teilverband":
          case "Berg":
            wreath2.value++;
            break;
          case "Eidgenössisch":
            wreath3.value++;
            break;
        }
      }
      // Store the original date for charting purposes
      if (item.expand?.place) {
        item.expand.place.originalDate = item.expand.place.year;
        item.expand.place.year = item.expand.place.year.split("-")[0];
      }
    });

    rankingsData.value = data as unknown as RankingData[];
  } catch (error) {
    console.error("Error loading rankings data:", error);
    rankingsData.value = [];
  } finally {
    loadingRankings.value = false;
  }
};

const calculateWinDrawLossRatio = (): ChartData | null => {
  if (!rankingsData.value.length) return null;

  const documentStyle = getComputedStyle(document.body);
  const counts = rankingsData.value.reduce(
    (acc, { result }) => {
      const win = (result.match(/\+/g) || []).length;
      const draw = (result.match(/-/g) || []).length;
      const loss = (result.match(/o/g) || []).length;

      return {
        win: acc.win + win,
        draw: acc.draw + draw,
        loss: acc.loss + loss,
      };
    },
    { win: 0, draw: 0, loss: 0 },
  );

  return {
    labels: ["Sieg", "Gestellt", "Niederlage"],
    datasets: [
      {
        data: [counts.win, counts.draw, counts.loss],
        backgroundColor: [
          documentStyle.getPropertyValue("--green-500"),
          documentStyle.getPropertyValue("--yellow-500"),
          documentStyle.getPropertyValue("--red-500"),
        ],
        hoverBackgroundColor: [
          documentStyle.getPropertyValue("--green-400"),
          documentStyle.getPropertyValue("--yellow-400"),
          documentStyle.getPropertyValue("--red-400"),
        ],
      },
    ],
  };
};

const calculateWinDrawLossGraph = (): GraphData | null => {
  if (!rankingsData.value.length) return null;

  const documentStyle = getComputedStyle(document.body);
  const graphArray = rankingsData.value.reduce(
    (accumulator, { result, expand }) => {
      let key: string;

      if (selectedYear.value.year === "Alle") {
        // When "Alle" is selected, group by year only
        key = expand.place.year;
      } else {
        // When a specific year is selected, group by individual places with date
        const originalDate = expand.place.originalDate || expand.place.year;
        // Format date as "MM.YYYY" or just use the place name if date is not available
        if (originalDate && originalDate.includes("-")) {
          const dateParts = originalDate.split("-");
          if (dateParts.length >= 2) {
            const month = dateParts[1];
            const year = dateParts[0];
            key = `${month}.${year}`;
          } else {
            key = expand.place.name;
          }
        } else {
          key = expand.place.name;
        }
      }

      const win = (result.match(/\+/g) || []).length;
      const draw = (result.match(/-/g) || []).length;
      const loss = (result.match(/o/g) || []).length;

      if (!accumulator[key]) {
        accumulator[key] = { win: 0, draw: 0, loss: 0, total: 0 };
      }

      accumulator[key].win += win;
      accumulator[key].draw += draw;
      accumulator[key].loss += loss;
      accumulator[key].total += win + draw + loss;
      return accumulator;
    },
    {} as Record<
      string,
      {
        win: number;
        draw: number;
        loss: number;
        total: number;
        winPercentage?: number;
        drawPercentage?: number;
        lossPercentage?: number;
      }
    >,
  );

  // Calculate percentages
  Object.values(graphArray).forEach((yearData) => {
    if (yearData.total > 0) {
      yearData.winPercentage = (yearData.win / yearData.total) * 100;
      yearData.drawPercentage = (yearData.draw / yearData.total) * 100;
      yearData.lossPercentage = (yearData.loss / yearData.total) * 100;
    }
  });

  // Use fallback colors if CSS variables are not available
  const green500 = documentStyle.getPropertyValue("--green-500") || "#22c55e";
  const yellow500 = documentStyle.getPropertyValue("--yellow-500") || "#eab308";
  const red500 = documentStyle.getPropertyValue("--red-500") || "#ef4444";
  const green400 = documentStyle.getPropertyValue("--green-400") || "#4ade80";
  const yellow400 = documentStyle.getPropertyValue("--yellow-400") || "#facc15";
  const red400 = documentStyle.getPropertyValue("--red-400") || "#f87171";

  // Sort labels chronologically when a specific year is selected
  let sortedLabels = Object.keys(graphArray);
  if (selectedYear.value.year !== "Alle") {
    sortedLabels = sortedLabels.sort((a, b) => {
      // If both are date formats (MM.YYYY), sort chronologically
      if (a.includes(".") && b.includes(".")) {
        const [monthA, yearA] = a.split(".");
        const [monthB, yearB] = b.split(".");
        if (yearA === yearB) {
          return parseInt(monthA) - parseInt(monthB);
        }
        return parseInt(yearA) - parseInt(yearB);
      }
      // If one is a date format and the other isn't, put dates first
      if (a.includes(".") && !b.includes(".")) return -1;
      if (!a.includes(".") && b.includes(".")) return 1;
      // Otherwise sort alphabetically
      return a.localeCompare(b);
    });
  }

  return {
    labels: sortedLabels,
    datasets: [
      {
        label: "Sieg",
        data: sortedLabels.map((key) => {
          const object = graphArray[key];
          return {
            winPercentage: object.winPercentage,
            win: object.win,
          };
        }),
        parsing: {
          xAxisKey: "win",
          yAxisKey: "winPercentage",
        },
        backgroundColor: [green500],
        hoverBackgroundColor: [green400],
      },
      {
        label: "Gestellt",
        data: sortedLabels.map((key) => {
          const object = graphArray[key];
          return {
            drawPercentage: object.drawPercentage,
            draw: object.draw,
          };
        }),
        parsing: {
          xAxisKey: "draw",
          yAxisKey: "drawPercentage",
        },
        backgroundColor: [yellow500],
        hoverBackgroundColor: [yellow400],
      },
      {
        label: "Niederlage",
        data: sortedLabels.map((key) => {
          const object = graphArray[key];
          return {
            lossPercentage: object.lossPercentage,
            loss: object.loss,
          };
        }),
        parsing: {
          xAxisKey: "loss",
          yAxisKey: "lossPercentage",
        },
        backgroundColor: [red500],
        hoverBackgroundColor: [red400],
      },
    ],
  };
};

const findTopOpponents = async (): Promise<void> => {
  try {
    loadingTopOpponents.value = true;

    const data = await pocketbase.collection("bouts").getFullList(200, {
      filter: `wrestler.id = "${wrestlerId.value}" && result = "o"`,
      expand: "opponent,place",
      sort: "-place.year,-created",
      fields:
        "id,result,points,expand.opponent.id,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name,expand.place.year",
    });

    // Group by opponent and count losses
    const opponentCounts = data.reduce(
      (acc, item) => {
        const opponentId = item.expand.opponent.id;
        const { name, vorname } = item.expand.opponent;

        if (acc[opponentId]) {
          acc[opponentId].count++;
        } else {
          acc[opponentId] = { count: 1, name, vorname };
        }
        return acc;
      },
      {} as Record<string, { count: number; name: string; vorname: string }>,
    );

    // Convert to array and sort by count
    topOpponentsData.value = Object.entries(opponentCounts)
      .sort((a, b) => b[1].count - a[1].count)
      .slice(0, 5)
      .map(([id, opponentData]) => ({
        id,
        ...opponentData,
      }));
  } catch (error) {
    console.error("Error finding top opponents:", error);
    topOpponentsData.value = [];
  } finally {
    loadingTopOpponents.value = false;
  }
};

const findBouts = async (): Promise<void> => {
  if (!selectedOpponent.value) return;

  try {
    loadingBouts.value = true;

    const data = await pocketbase.collection("bouts").getFullList(200, {
      filter: `wrestler.id = "${wrestlerId.value}" && opponent.id = "${selectedOpponent.value}"`,
      expand: "place",
      sort: "-place.year,-created",
      fields:
        "id,result,points,expand.place.id,expand.place.name,expand.place.year",
    });

    data.forEach((item: BoutData) => {
      item.expand.place.year = item.expand.place.year.split("-")[0];
    });

    boutsData.value = data;
  } catch (error) {
    console.error("Error finding bouts:", error);
    boutsData.value = [];
  } finally {
    loadingBouts.value = false;
  }
};

const yearSelected = async (): Promise<void> => {
  await Promise.all([loadRankingsData(), loadBoutsData(), loadEloData()]);
};

// Navigation functions
const wrestlerRowClick = async (wid: string): Promise<void> => {
  try {
    await navigateTo(`/wrestler/${wid}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

const wrestlerPlaceRowClick = async (
  wid: string,
  pid: string,
): Promise<void> => {
  try {
    await navigateTo(`/wrestler/${wid}-${pid}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

const placeRowClick = async (pid: string): Promise<void> => {
  try {
    await navigateTo(`/rankings/${pid}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

// Chart options
const chartOptions = ref({
  animation: {
    animateRotate: false,
  },
  plugins: {
    legend: {
      labels: {
        usePointStyle: true,
      },
    },
  },
  responsive: true,
});

const addLabel = (tooltipItems: any): string => {
  let amount = "0";

  if ("win" in tooltipItems.raw) {
    amount = tooltipItems.raw.win.toString();
  } else if ("draw" in tooltipItems.raw) {
    amount = tooltipItems.raw.draw.toString();
  } else if ("loss" in tooltipItems.raw) {
    amount = tooltipItems.raw.loss.toString();
  }

  return `Anzahl: ${amount}`;
};

const addHeader = (tooltipItems: any): string => {
  let amount = "0";

  if ("winPercentage" in tooltipItems[0].raw) {
    amount = tooltipItems[0].raw.winPercentage.toFixed(0);
  } else if ("drawPercentage" in tooltipItems[0].raw) {
    amount = tooltipItems[0].raw.drawPercentage.toFixed(0);
  } else if ("lossPercentage" in tooltipItems[0].raw) {
    amount = tooltipItems[0].raw.lossPercentage.toFixed(0);
  }

  return `Prozent: ${amount}%`;
};

const graphOptions = ref({
  maintainAspectRatio: false,
  aspectRatio: 0.6,
  plugins: {
    tooltip: {
      callbacks: {
        title: addHeader,
        label: addLabel,
      },
    },
  },
});

// Watch for data changes to update charts
watch(
  rankingsData,
  () => {
    ratioWinDrawLoss.value = calculateWinDrawLossRatio();
    graphWinDrawLoss.value = calculateWinDrawLossGraph();
  },
  { deep: true, immediate: true },
);

// Lifecycle
onMounted(async () => {
  try {
    await Promise.all([loadWrestlerData(), loadEloData()]);
    loadingWrestler.value = false;

    await Promise.all([loadRankingsData(), loadBoutsData()]);
  } catch (error) {
    console.error("Error in component mount:", error);
    loadingWrestler.value = false;
  }
});
</script>

<template>
  <div>
    <h1 class="sr-only">Schwinger Profil</h1>
    <ProgressSpinner v-if="loadingWrestler" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title>
          {{ wrestlerData.vorname }} {{ wrestlerData.name }}
        </template>
        <template #subtitle
          >Kränze: {{ wreath1 }}* / {{ wreath2 }}** / {{ wreath3 }}***
          <br />Elo-Rating: {{ eloData.rating }}</template
        >
        <template #content>
          <div v-if="wrestlerData.expand.status">
            <p v-if="wrestlerData.category">
              Status: {{ wrestlerData.expand.status.status }} (aktiv)
            </p>
            <p v-else>
              Status: {{ wrestlerData.expand.status.status }} (inaktiv)
            </p>
          </div>
          <p>Jahrgang: {{ wrestlerData.year }}</p>
          <p>Schwingklub: {{ wrestlerData.expand.club.name }}</p>
          <p v-if="wrestlerData.expand.club.expand">
            Gauverband: {{ wrestlerData.expand.club.expand.canton.name }}
          </p>
          <p
            v-if="
              wrestlerData.expand.club.expand &&
              wrestlerData.expand.club.expand.canton.expand
            "
          >
            Schwingerverband:
            {{
              wrestlerData.expand.club.expand.canton.expand.association
                .abbreviation
            }}
          </p>
          <div
            v-if="
              wrestlerData.expand.metadata?.website ||
              wrestlerData.expand.metadata?.instagram
            "
            class="flex gap-2 mt-2"
          >
            <NuxtLink
              v-if="wrestlerData.expand.metadata?.website"
              :to="wrestlerData.expand.metadata.website"
              target="_blank"
            >
              <Icon name="mdi:web" class="inline-block" />
            </NuxtLink>
            <NuxtLink
              v-if="wrestlerData.expand.metadata?.instagram"
              :to="wrestlerData.expand.metadata.instagram"
              target="_blank"
            >
              <Icon name="mdi:instagram" class="inline-block" />
            </NuxtLink>
          </div>
        </template>
      </Card>
    </div>
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title> Top 5 Gegner </template>
        <template #content>
          <Button
            v-if="loadingTopOpponents"
            type="button"
            label="Laden"
            icon="pi pi-search"
            class="ml-2 mt-2 md:mt-0 bg-yellow-900 border-2 border-yellow-800"
            :loading="loadingBouts"
            @click="findTopOpponents"
          />
          <ul v-else>
            <li
              v-for="(value, key) in topOpponentsData"
              :key="value.id"
              @click="wrestlerRowClick(value.id)"
            >
              {{ key + 1 }}: {{ value.name }} {{ value.vorname }} ({{
                value.count
              }}
              verloren)
            </li>
          </ul>
        </template>
      </Card>
    </div>
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title>Jahr</template>
        <template #content>
          <Dropdown
            v-model="selectedYear"
            :options="years"
            option-label="year"
            placeholder="Wähle ein Jahr"
            class="w-fit mb-2 text-stone-700 font-bold"
            @change="yearSelected()"
          />
        </template>
      </Card>
    </div>
    <ProgressSpinner v-if="loadingRankings" />
    <div
      v-else
      class="justify-center flex md:align-items-center align-items-stretch flex-wrap"
    >
      <Card
        v-if="ratioWinDrawLoss"
        class="w-11/12 md:w-9/12 lg:w-22rem mt-2 md:mr-2"
      >
        <template #title>Statistiken</template>
        <template #content>
          <p>Ø Rang: {{ averageRank }}</p>
          <p>Ø Punkte: {{ averagePoints }}</p>
          <div class="relative w-full md:max-w-80 md:min-w-80">
            <Chart
              type="pie"
              :data="ratioWinDrawLoss"
              :options="chartOptions"
            />
          </div>
        </template>
      </Card>
      <Card v-if="graphWinDrawLoss" class="w-11/12 md:w-7/12 mt-2 md:mr-2">
        <template #title />
        <template #content>
          <div>
            <Chart
              type="line"
              :data="graphWinDrawLoss"
              :options="graphOptions"
              class="h-20rem"
            />
          </div>
        </template>
      </Card>
    </div>
    <ProgressSpinner v-if="loadingRankings" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-11/12 md:w-9/12">
        <template #title>Resultate</template>
        <template #content>
          <DataView
            v-if="Object.keys(rankingsData).length !== 0"
            :value="rankingsData"
            paginator
            :rows="10"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-4 md:col-4">Schwingfest</p>
                <p v-if="layout === 'default'" class="col-1 md:col-2">Jahr</p>
                <p class="col-2 md:col-1">Rang</p>
                <p class="col-2 md:col-1">Punkte</p>
                <p class="col-4 md:col-1">Resultat</p>
                <p v-if="layout === 'default'" class="md:col-1">Schlussgang</p>
                <p v-if="layout === 'default'" class="md:col-2">
                  Kranz / Unfall
                </p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="
                    wrestlerPlaceRowClick(route.params.id, item.expand.place.id)
                  "
                >
                  <div class="grid">
                    <div class="col-4 md:col-4">
                      <p class="font-bold">
                        {{ item.expand.place.name }}
                      </p>
                    </div>
                    <div v-if="layout === 'default'" class="col-1 md:col-2">
                      <p class="font-bold">
                        {{ item.expand.place.year }}
                      </p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.rank }}{{ item.rank2 }}</p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.points }}</p>
                    </div>
                    <div class="col-4 md:col-1">
                      <p>{{ item.result }}</p>
                    </div>
                    <div v-if="layout === 'default'" class="md:col-1">
                      <Icon
                        v-if="item.final"
                        class="flex content-center"
                        name="gis:flag-finish"
                      />
                    </div>
                    <div v-if="layout === 'default'" class="md:col-2">
                      <Icon
                        v-if="item.wreath"
                        class="flex content-center"
                        name="mingcute:wreath-fill"
                      />
                      <Icon
                        v-if="item.status === 'Unfall'"
                        class="flex content-center"
                        name="game-icons:arm-bandage"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
          <p v-else>Keine Resultate vorhanden</p>
        </template>
      </Card>
    </div>
    <div class="justify-content-center align-content-center display: flex mt-2">
      <Card class="w-11/12 md:w-9/12">
        <template #title>1 vs. 1</template>
        <template #content>
          <Dropdown
            v-model="selectedOpponent"
            :options="opponentsData"
            :option-label="displayOpponent"
            option-value="id"
            filter
            :filter-fields="['name', 'vorname']"
            :loading="loadingOpponents"
            placeholder="Wähle einen Gegner"
            empty-message="Keine Gegner gefunden"
            class="w-full md:w-14rem"
          />
          <Button
            type="button"
            label="Suchen"
            icon="pi pi-search"
            class="ml-2 mt-2 md:mt-0 bg-yellow-900 border-2 border-yellow-800"
            :loading="loadingBouts"
            @click="findBouts"
          />
          <DataView :value="boutsData" data-key="id" class="mt-4">
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="placeRowClick(item.expand.place.id)"
                >
                  <div class="grid">
                    <div class="col-4 md:col-4">
                      <strong> {{ item.expand.place.name }}</strong>
                    </div>
                    <div class="col-4 md:col-2">
                      <p>{{ item.expand.place.year }}</p>
                    </div>
                    <div class="col-4 md:col-2">
                      <p>{{ item.points }}</p>
                    </div>
                    <div class="col-4 md:col-2">
                      <p>{{ item.result }}</p>
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

<style scoped>
:deep(.p-card-content) {
  padding: 0;
}
</style>
