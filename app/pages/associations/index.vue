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
}

interface CantonData {
  id: string;
  name: string;
  association: string;
  wrestlerAmount: number;
  wrestlerActive: number;
}

interface ClubData {
  id: string;
  name: string;
  canton: string;
  wrestlerAmount: number;
  wrestlerActive: number;
}

interface MergedData extends Feature {
  wrestlerActive?: number;
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
        fields: "id,name,abbreviation,wrestlerAmount,wrestlerActive",
      });

    associationData.value = data;
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
        fields: "id,name,association,wrestlerAmount,wrestlerActive",
      });

    fullCantonData.value = data;
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
      mergedData[name] = { ...mergedData[name], ...item };
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
      mergedData[name] = { ...mergedData[name], ...item };
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
        if (mergedData.Bern?.wrestlerActive) {
          mergedData.Bern.wrestlerActive += item.wrestlerActive;
        } else if (mergedData.Bern) {
          mergedData.Bern = { ...mergedData.Bern, ...item };
        }
        break;
      case "Ob- und Nidwalden":
        if (mergedData.Obwalden) {
          mergedData.Obwalden = { ...mergedData.Obwalden, ...item };
        }
        if (mergedData.Nidwalden) {
          mergedData.Nidwalden = { ...mergedData.Nidwalden, ...item };
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

const initializeChart = (): void => {
  try {
    const nation: Feature = topojson.feature(
      maps as unknown as Topology,
      maps.objects.country as GeometryCollection,
    ).features[0];
    const cantons: Array<Feature> = topojson.feature(
      maps as unknown as Topology,
      maps.objects.cantons as GeometryCollection,
    ).features;

    // Merge data
    mergedAssociations.value = mergeAssociationData(
      cantons,
      associationData.value,
    );
    mergedCantons.value = mergeCantonData(cantons, fullCantonData.value);

    const config = {
      type: "choropleth",
      data: {
        labels: mergedAssociations.value.map(
          (d: MergedData) => d.properties?.name,
        ),
        datasets: [
          {
            label: "Teilverbände",
            outline: nation,
            showOutline: true,
            data: mergedAssociations.value.map((d: MergedData) => ({
              feature: d,
              value: d.wrestlerActive || 0,
            })),
          },
        ],
      },
      options: {
        plugins: {
          legend: {
            display: false,
          },
          datalabels: {
            align: "center",
            color: "#000",
            font: {
              size: "12",
              weight: "bold",
            },
            textShadowBlur: 10,
            textShadowColor: "#000",
            formatter: (v: any) => {
              return (
                v.feature.properties?.name +
                ": " +
                (v.feature.wrestlerActive || 0)
              );
            },
            display: function (context: any) {
              return context.active;
            },
          },
        },
        onClick: (evt: ChartClickEvent) => {
          const res = chart.value?.getElementsAtEventForMode(
            evt,
            "nearest",
            { intersect: true },
            true,
          );
          if (res && res.length !== 0) {
            const route = `/associations/association/${res[0].element.feature.id}`;
            navigateTo(route);
          }
        },
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
    };

    Chart.register(
      ChoroplethController,
      GeoFeature,
      ColorScale,
      ProjectionScale,
      ChartDataLabels,
    );

    const canvasData = document.getElementById(
      "canvasData",
    ) as HTMLCanvasElement;
    const ctxData = canvasData.getContext("2d");

    if (!ctxData || !(ctxData instanceof CanvasRenderingContext2D)) {
      throw new Error("Canvas context not available");
    }

    chart.value = new Chart(ctxData, config as any);
  } catch (error) {
    console.error("Error initializing chart:", error);
    navigateTo("/error");
  }
};

const onTabOpen = (event: TabEvent): void => {
  try {
    if (!associationData.value[event.index as number]) return;

    currentAssociation.value = associationData.value[event.index as number].id;
    currentSelection.value = "Kanton";

    if (!chart.value) return;

    chart.value.data.labels = mergedCantons.value.map(
      (d: MergedData) => d.properties?.name,
    );
    chart.value.data.datasets[0].label = "Kantone";
    chart.value.data.datasets[0].data = mergedCantons.value.map(
      (d: MergedData) => ({
        feature: d,
        value: d.wrestlerActive || 0,
      }),
    );

    chart.value.options.onClick = (evt: ChartClickEvent) => {
      const res = chart.value?.getElementsAtEventForMode(
        evt,
        "nearest",
        { intersect: true },
        true,
      );
      if (res && res.length !== 0) {
        let route: string;
        if (res[0].element.feature.properties?.name === "Bern") {
          route = `/associations/association/${res[0].element.feature.association}`;
        } else {
          route = `/associations/canton/${res[0].element.feature.id}`;
        }
        navigateTo(route);
      }
    };

    chart.value.update();
  } catch (error) {
    console.error("Error in tab open:", error);
  }
};

const onTabClose = (): void => {
  try {
    currentSelection.value = "Teilverband";

    if (!chart.value) return;

    chart.value.data.labels = mergedAssociations.value.map(
      (d: MergedData) => d.properties?.name,
    );
    chart.value.data.datasets[0].label = "Teilverbände";
    chart.value.data.datasets[0].data = mergedAssociations.value.map(
      (d: MergedData) => ({
        feature: d,
        value: d.wrestlerActive || 0,
      }),
    );

    chart.value.options.onClick = (evt: ChartClickEvent) => {
      const res = chart.value?.getElementsAtEventForMode(
        evt,
        "nearest",
        { intersect: true },
        true,
      );
      if (res && res.length !== 0) {
        const route = `/associations/association/${res[0].element.feature.id}`;
        navigateTo(route);
      }
    };

    chart.value.update();
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
        fields: "id,name,canton,wrestlerAmount,wrestlerActive",
      });

    clubData.value = data;
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
    <div class="flex justify-center">
      <div class="h-fit w-screen md:w-4">
        <p
          class="text-xl font-bold mt-1 md:mt-2 mb-1 md:mb-2 text-center text-stone-800"
        >
          Anzahl Schwinger pro {{ currentSelection }}
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
            association.wrestlerActive +
            '/' +
            association.wrestlerAmount +
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
                canton.wrestlerActive +
                '/' +
                canton.wrestlerAmount +
                ' aktive Schwinger)'
              "
            >
              <ul>
                <li v-for="value in clubData" :key="value.id">
                  <NuxtLink
                    :to="'/associations/club/' + value.id"
                    class="cursor-pointer hover:bg-gray-200"
                    >{{ value.name }} ({{ value.wrestlerActive }}/{{
                      value.wrestlerAmount
                    }}
                    aktive Schwinger)</NuxtLink
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
