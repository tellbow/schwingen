<script setup lang="ts">
// Set SEO metadata for the associations page
// import { ChartConfiguration } from "chart.js";
import { Chart } from "chart.js";
import type { Feature } from "geojson";
import {
  ChoroplethController,
  GeoFeature,
  ColorScale,
  ProjectionScale,
  topojson,
} from "chartjs-chart-geo";
import ChartDataLabels from "chartjs-plugin-datalabels";
import type { GeometryCollection, Topology } from "topojson-specification";
import maps from "~/public/topo/swiss-maps-modified.json";
import bernGauverbandGeo from "~/public/topo/bern-gauverband.json";
import { useStructuredData } from "~/composables/useStructuredData";

useSeo({
  title: "Verbände - Tellbow",
  description:
    "Übersicht über alle Teilverbände, Kantone und Vereine im Schweizer Schwingen. Interaktive Karte und detaillierte Statistiken.",
  keywords:
    "Schwingen Verbände, Teilverbände, Kantone, Vereine, ESV, Schweizer Schwingen, BKSV, ISV, NOSV, NWSV, SWSV",
});

// Set structured data for the associations page
const {
  createWebSite,
  createSportsOrganization,
  createBreadcrumbList,
  setStructuredData,
} = useStructuredData();
const config = useRuntimeConfig();

const websiteData = createWebSite({
  name: "Tellbow - Schwingen Verbände",
  url: `${config.public.baseUrl}/associations`,
  description:
    "Übersicht über alle Teilverbände, Kantone und Vereine im Schweizer Schwingen. Interaktive Karte und detaillierte Statistiken.",
  publisher: {
    name: "Tellbow",
    url: config.public.baseUrl,
    logo: `${config.public.baseUrl}/images/logos/tellbow_512x512.webp`,
    description: "Plattform für Schweizer Schwingen Statistiken und Analysen",
  },
});

const mainOrganization = createSportsOrganization({
  name: "Eidgenössischer Schwingerverband",
  url: "https://esv.ch",
  description: "Schweizerischer Dachverband für Schwingen",
});

const breadcrumbs = createBreadcrumbList([
  { name: "Home", url: config.public.baseUrl },
  { name: "Verbände", url: `${config.public.baseUrl}/associations` },
]);

setStructuredData([websiteData, mainOrganization, breadcrumbs]);

// Types
interface AssociationData {
  id: string;
  name: string;
  abbreviation: string;
  wrestlerAmount: number;
  wrestlerActive: number;
  wrestler1Star: number;
  wrestler2Star: number;
  wrestler3Star: number;
}

interface CantonData {
  id: string;
  name: string;
  association: string;
  wrestlerAmount: number;
  wrestlerActive: number;
  wrestler1Star: number;
  wrestler2Star: number;
  wrestler3Star: number;
}

interface ClubData {
  id: string;
  name: string;
  canton: string;
  wrestlerAmount: number;
  wrestlerActive: number;
  wrestler1Star: number;
  wrestler2Star: number;
  wrestler3Star: number;
}

interface MergedData extends Feature {
  wrestlerActive?: number;
  wrestlerAmount?: number;
  wrestler1Star?: number;
  wrestler2Star?: number;
  wrestler3Star?: number;
  id?: string;
  association?: string;
}

interface ChartClickEvent {
  element: {
    feature: {
      id: string;
      properties: {
        name: string;
      };
      association?: string;
    };
  };
}

interface TabEvent {
  index: string | number;
}

// Composables
const pocketbase = usePocketbase();

// Reactive state
const chart = shallowRef<Chart>();
const currentSelection = ref("Teilverband");
const associationData = ref<AssociationData[]>([]);
const mergedAssociations = ref<MergedData[]>([]);
const currentAssociation = ref<string | null>(null);
const fullCantonData = ref<CantonData[]>([]);
const mergedCantons = ref<MergedData[]>([]);
const currentCanton = ref<CantonData | null>(null);
const clubData = ref<ClubData[]>([]);
const loadingData = ref(true);

// Methods
const loadAssociationData = async (): Promise<void> => {
  try {
    const data = await pocketbase
      .collection("wrestlersByAssociation")
      .getFullList(10, {
        sort: "name",
        fields:
          "id,name,abbreviation,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star",
      });

    associationData.value = data as unknown as AssociationData[];
  } catch (error) {
    console.error("Error loading association data:", error);
    associationData.value = [];
  }
};

const loadCantonData = async (): Promise<void> => {
  try {
    const data = await pocketbase
      .collection("wrestlersByCanton")
      .getFullList(50, {
        sort: "name",
        fields:
          "id,name,association,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star",
      });

    fullCantonData.value = data as unknown as CantonData[];
  } catch (error) {
    console.error("Error loading canton data:", error);
    fullCantonData.value = [];
  }
};

const mergeAssociationData = (
  cantons: Feature[],
  associations: AssociationData[],
): MergedData[] => {
  const mergedData: Record<string, MergedData> = {};

  // Merge first dataset based on name
  for (const item of cantons) {
    if (item.properties) {
      const name = item.properties.name;
      mergedData[name] = {
        ...mergedData[name],
        ...item,
        id: item.id?.toString(),
      };
    }
  }

  // Merge second dataset based on name
  for (const item of associations) {
    const abbreviation = item.abbreviation;
    switch (abbreviation) {
      case "BKSV":
        mergedData.Bern = { ...mergedData.Bern, ...item };
        break;
      case "ISV": {
        const isv = [
          "Luzern",
          "Nidwalden",
          "Obwalden",
          "Schwyz",
          "Tessin",
          "Uri",
          "Zug",
        ];
        isv.forEach((canton) => {
          if (mergedData[canton]) {
            mergedData[canton].wrestlerActive = item.wrestlerActive;
            mergedData[canton].wrestler1Star = item.wrestler1Star;
            mergedData[canton].wrestler2Star = item.wrestler2Star;
            mergedData[canton].wrestler3Star = item.wrestler3Star;
            mergedData[canton].id = item.id;
          }
        });
        break;
      }
      case "NOSV": {
        const nosv = [
          "Appenzell Ausserrhoden",
          "Appenzell Innerrhoden",
          "Glarus",
          "Graubünden",
          "Schaffhausen",
          "St. Gallen",
          "Thurgau",
          "Zürich",
        ];
        nosv.forEach((canton) => {
          if (mergedData[canton]) {
            mergedData[canton].wrestlerActive = item.wrestlerActive;
            mergedData[canton].wrestler1Star = item.wrestler1Star;
            mergedData[canton].wrestler2Star = item.wrestler2Star;
            mergedData[canton].wrestler3Star = item.wrestler3Star;
            mergedData[canton].id = item.id;
          }
        });
        break;
      }
      case "NWSV": {
        const nwsv = ["Aargau", "Basel-Stadt", "Baselland", "Solothurn"];
        nwsv.forEach((canton) => {
          if (mergedData[canton]) {
            mergedData[canton].wrestlerActive = item.wrestlerActive;
            mergedData[canton].wrestler1Star = item.wrestler1Star;
            mergedData[canton].wrestler2Star = item.wrestler2Star;
            mergedData[canton].wrestler3Star = item.wrestler3Star;
            mergedData[canton].id = item.id;
          }
        });
        break;
      }
      case "SWSV": {
        const swsv = [
          "Fribourgeoise",
          "Genevoise",
          "Jura",
          "Neuchâteloise",
          "Valaisanne",
          "Vaudoise",
        ];
        swsv.forEach((canton) => {
          if (mergedData[canton]) {
            mergedData[canton].wrestlerActive = item.wrestlerActive;
            mergedData[canton].wrestler1Star = item.wrestler1Star;
            mergedData[canton].wrestler2Star = item.wrestler2Star;
            mergedData[canton].wrestler3Star = item.wrestler3Star;
            mergedData[canton].id = item.id;
          }
        });
        break;
      }
    }
  }

  return Object.values(mergedData);
};

const mergeCantonData = (
  cantons: Feature[],
  cantonData: CantonData[],
): MergedData[] => {
  const mergedData: Record<string, MergedData> = {};

  // Merge first dataset based on name
  for (const item of cantons) {
    if (item.properties) {
      const name = item.properties.name;
      mergedData[name] = {
        ...mergedData[name],
        ...item,
        id: item.id?.toString(),
      };
    }
  }

  // Merge second dataset based on name
  for (const item of cantonData) {
    const name = item.name;
    switch (name) {
      case "Berner-Jura":
      case "Emmental":
      case "Mittelland":
      case "Oberaargau":
      case "Oberland":
      case "Seeland":
        if (mergedData.Bern?.wrestlerActive !== undefined) {
          mergedData.Bern.wrestlerActive += item.wrestlerActive;
          mergedData.Bern.wrestler1Star =
            (mergedData.Bern.wrestler1Star || 0) + item.wrestler1Star;
          mergedData.Bern.wrestler2Star =
            (mergedData.Bern.wrestler2Star || 0) + item.wrestler2Star;
          mergedData.Bern.wrestler3Star =
            (mergedData.Bern.wrestler3Star || 0) + item.wrestler3Star;
        } else if (mergedData.Bern) {
          mergedData.Bern = { ...mergedData.Bern, ...item };
        }
        break;
      case "Ob- und Nidwalden":
        if (mergedData.Obwalden) {
          mergedData.Obwalden.wrestlerActive =
            (mergedData.Obwalden.wrestlerActive || 0) + item.wrestlerActive;
          mergedData.Obwalden.wrestler1Star =
            (mergedData.Obwalden.wrestler1Star || 0) + item.wrestler1Star;
          mergedData.Obwalden.wrestler2Star =
            (mergedData.Obwalden.wrestler2Star || 0) + item.wrestler2Star;
          mergedData.Obwalden.wrestler3Star =
            (mergedData.Obwalden.wrestler3Star || 0) + item.wrestler3Star;
        }
        if (mergedData.Nidwalden) {
          mergedData.Nidwalden.wrestlerActive =
            (mergedData.Nidwalden.wrestlerActive || 0) + item.wrestlerActive;
          mergedData.Nidwalden.wrestler1Star =
            (mergedData.Nidwalden.wrestler1Star || 0) + item.wrestler1Star;
          mergedData.Nidwalden.wrestler2Star =
            (mergedData.Nidwalden.wrestler2Star || 0) + item.wrestler2Star;
          mergedData.Nidwalden.wrestler3Star =
            (mergedData.Nidwalden.wrestler3Star || 0) + item.wrestler3Star;
        }
        break;
      case "Appenzell":
        if (mergedData["Appenzell Ausserrhoden"]) {
          mergedData["Appenzell Ausserrhoden"] = {
            ...mergedData["Appenzell Ausserrhoden"],
            ...item,
          };
        }
        if (mergedData["Appenzell Innerrhoden"]) {
          mergedData["Appenzell Innerrhoden"] = {
            ...mergedData["Appenzell Innerrhoden"],
            ...item,
          };
        }
        break;
      default:
        mergedData[name] = { ...mergedData[name], ...item };
    }
  }

  return Object.values(mergedData);
};

const nation = shallowRef<Feature | null>(null);

const buildChart = (
  displayData: MergedData[],
  label: string,
  onClickHandler: (evt: ChartClickEvent) => void,
): void => {
  chart.value?.destroy();

  const canvasData = document.getElementById("canvasData") as HTMLCanvasElement;
  const ctxData = canvasData?.getContext("2d");
  if (!ctxData || !(ctxData instanceof CanvasRenderingContext2D)) return;

  chart.value = new Chart(ctxData, {
    type: "choropleth",
    data: {
      labels: displayData.map((d: MergedData) => d.properties?.name),
      datasets: [
        {
          label,
          outline: nation.value!,
          showOutline: true,
          data: displayData.map((d: MergedData) => ({
            feature: d,
            value: d.wrestlerActive || 0,
          })),
        },
      ],
    },
    options: {
      plugins: {
        legend: { display: false },
        datalabels: {
          align: "center",
          color: "#000",
          font: { size: "12", weight: "bold" },
          textShadowBlur: 10,
          textShadowColor: "#000",
          formatter: (v: any) =>
            v.feature.properties?.name + ": " + (v.feature.wrestlerActive || 0),
          display: (context: any) => context.active,
        },
      },
      onClick: onClickHandler,
      scales: {
        projection: {
          axis: "x",
          projection: "mercator",
          projectionOffset: [-30, 0],
        },
        color: {
          axis: "x",
          quantize: 10,
          interpolate: "oranges",
        },
      },
    },
  } as any);
};

const initializeChart = (): void => {
  try {
    const cantons: Array<Feature> = topojson.feature(
      maps as unknown as Topology,
      maps.objects.cantons as GeometryCollection,
    ).features;

    nation.value = topojson.feature(
      maps as unknown as Topology,
      maps.objects.country as GeometryCollection,
    ).features[0];

    mergedAssociations.value = mergeAssociationData(
      cantons,
      associationData.value,
    );
    mergedCantons.value = mergeCantonData(cantons, fullCantonData.value);

    Chart.register(
      ChoroplethController,
      GeoFeature,
      ColorScale,
      ProjectionScale,
      ChartDataLabels,
    );

    buildChart(
      mergedAssociations.value,
      "Teilverbände",
      (evt: ChartClickEvent) => {
        const res = chart.value?.getElementsAtEventForMode(
          evt,
          "nearest",
          { intersect: true },
          true,
        );
        if (res && res.length !== 0) {
          navigateTo(`/associations/association/${res[0].element.feature.id}`);
        }
      },
    );
  } catch (error) {
    console.error("Error initializing chart:", error);
    navigateTo("/error");
  }
};

const mergeBKSVData = (): MergedData[] => {
  // Build a map of canton name → canton data for BKSV sub-regions
  const bksvCantons = fullCantonData.value.filter(
    (c: CantonData) => c.association === currentAssociation.value,
  );
  const byName = Object.fromEntries(bksvCantons.map((c) => [c.name, c]));

  // Take all non-Bern cantons from mergedCantons, then add the 6 Gauverband features
  const withoutBern = mergedCantons.value.filter(
    (d: MergedData) => d.properties?.name !== "Bern",
  );

  const gauverbandFeatures: MergedData[] = (
    bernGauverbandGeo as unknown as GeoJSON.FeatureCollection
  ).features.map((f) => {
    const name = f.properties?.name as string;
    const canton = byName[name];
    return {
      ...f,
      id: canton?.id,
      association: canton?.association,
      wrestlerActive: canton?.wrestlerActive ?? 0,
      wrestlerAmount: canton?.wrestlerAmount ?? 0,
      wrestler1Star: canton?.wrestler1Star ?? 0,
      wrestler2Star: canton?.wrestler2Star ?? 0,
      wrestler3Star: canton?.wrestler3Star ?? 0,
    } as MergedData;
  });

  return [...withoutBern, ...gauverbandFeatures];
};

const onTabOpen = (event: TabEvent): void => {
  try {
    if (!associationData.value[event.index as number]) return;

    const association = associationData.value[event.index as number];
    currentAssociation.value = association.id;
    const isBKSV = association.abbreviation === "BKSV";
    currentSelection.value = isBKSV ? "Gauverband" : "Kanton";

    const displayData = isBKSV ? mergeBKSVData() : mergedCantons.value;

    buildChart(
      displayData,
      isBKSV ? "Gauverbände" : "Kantone",
      (evt: ChartClickEvent) => {
        const res = chart.value?.getElementsAtEventForMode(
          evt,
          "nearest",
          { intersect: true },
          true,
        );
        if (res && res.length !== 0) {
          const feature = res[0].element.feature;
          const route = feature.id
            ? `/associations/canton/${feature.id}`
            : `/associations/association/${feature.association}`;
          navigateTo(route);
        }
      },
    );
  } catch (error) {
    console.error("Error in tab open:", error);
  }
};

const onTabClose = (): void => {
  try {
    currentSelection.value = "Teilverband";

    buildChart(
      mergedAssociations.value,
      "Teilverbände",
      (evt: ChartClickEvent) => {
        const res = chart.value?.getElementsAtEventForMode(
          evt,
          "nearest",
          { intersect: true },
          true,
        );
        if (res && res.length !== 0) {
          navigateTo(`/associations/association/${res[0].element.feature.id}`);
        }
      },
    );
  } catch (error) {
    console.error("Error in tab close:", error);
  }
};

const onSubTabOpen = async (event: TabEvent): Promise<void> => {
  try {
    if (!currentAssociation.value || !fullCantonData.value) return;

    const filteredCantons = fullCantonData.value.filter(
      (canton: CantonData) => canton.association === currentAssociation.value,
    );

    if (!filteredCantons[event.index as number]) return;

    currentCanton.value = filteredCantons[event.index as number];

    const data = await pocketbase
      .collection("wrestlersByClub")
      .getFullList(200, {
        sort: "name",
        filter: `canton.id = "${currentCanton.value.id}"`,
        fields:
          "id,name,canton,wrestlerAmount,wrestlerActive,wrestler1Star,wrestler2Star,wrestler3Star",
      });

    clubData.value = data as unknown as ClubData[];
  } catch (error) {
    console.error("Error loading club data:", error);
    clubData.value = [];
  }
};

const getCantons = (associationId: string): CantonData[] => {
  if (!fullCantonData.value) return [];
  return fullCantonData.value.filter(
    (canton: CantonData) => canton.association === associationId,
  );
};

// Lifecycle
onMounted(async () => {
  try {
    await Promise.all([loadAssociationData(), loadCantonData()]);

    initializeChart();
  } catch (error) {
    console.error("Error in component mount:", error);
  } finally {
    loadingData.value = false;
  }
});
</script>
<template>
  <div>
    <h1 class="sr-only">Verbände - Tellbow</h1>
    <div class="flex justify-center">
      <div class="h-fit w-screen md:w-4">
        <p
          class="text-xl font-bold mt-1 md:mt-2 mb-1 md:mb-2 text-center text-stone-800"
        >
          Anzahl Schwinger nach Status pro {{ currentSelection }}
        </p>
        <canvas id="canvasData" ref="canvasData" />
      </div>
    </div>
    <div
      class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-3 md:mt-6"
    >
      <ProgressSpinner v-if="loadingData" />
      <Accordion
        v-else
        lazy
        class="w-12 sm:w-10 md:w-8 lg:w-6 xl:w-4"
        @tab-open="onTabOpen($event)"
        @tab-close="onTabClose()"
      >
        <AccordionTab
          v-for="association in associationData"
          :key="association.id"
          :header="
            association.abbreviation +
            ' (' +
            association.wrestler1Star +
            '*' +
            ' / ' +
            association.wrestler2Star +
            '**' +
            ' / ' +
            association.wrestler3Star +
            '***' +
            ' / ' +
            association.wrestlerActive +
            ' aktive Schwinger)'
          "
        >
          <Accordion lazy @tab-open="onSubTabOpen($event)">
            <AccordionTab
              v-for="canton in getCantons(association.id)"
              :key="canton.id"
              :header="
                canton.name +
                ' (' +
                canton.wrestler1Star +
                '*' +
                ' / ' +
                canton.wrestler2Star +
                '**' +
                ' / ' +
                canton.wrestler3Star +
                '***' +
                ' / ' +
                canton.wrestlerActive +
                ' aktive Schwinger)'
              "
            >
              <ul>
                <li v-for="value in clubData" :key="value.id">
                  <NuxtLink
                    :to="'/associations/club/' + value.id"
                    class="cursor-pointer hover:bg-gray-200"
                    >{{ value.name }} ({{ value.wrestler1Star }}* /
                    {{ value.wrestler2Star }}** / {{ value.wrestler3Star }}*** /
                    {{ value.wrestlerActive }} aktive Schwinger)</NuxtLink
                  >
                </li>
              </ul>
            </AccordionTab>
          </Accordion>
        </AccordionTab>
      </Accordion>
    </div>
  </div>
</template>
