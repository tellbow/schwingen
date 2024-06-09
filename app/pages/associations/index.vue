<script setup lang="ts">
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

const pocketbase = usePocketbase();

const chart = shallowRef();
const currentSelection = ref("Teilverband");
const associationData = ref();
const mergedAssociations = ref();
const currentAssociation = ref();
const fullCantonData = ref();
const mergedCantons = ref();
const currentCanton = ref();
const clubData = ref();
const loadingData = ref(true);

onMounted(async () => {
  const nation: Feature = topojson.feature(
    maps as unknown as Topology,
    maps.objects.country as GeometryCollection,
  ).features[0];
  const cantons: Array<Feature> = topojson.feature(
    maps as unknown as Topology,
    maps.objects.cantons as GeometryCollection,
  ).features;
  await pocketbase
    .collection("wrestlersByAssociation")
    .getFullList(10 /* batch size */, {
      sort: "name",
      fields: "id,name,abbreviation,wrestlerAmount,wrestlerActive",
    })
    .then((data) => {
      associationData.value = data;

      const mergedData: any = {};

      // Merge first dataset based on name
      for (const item of cantons) {
        if (item.properties) {
          const name = item.properties.name;
          mergedData[name] = { ...mergedData[name], ...item };
        }
      }

      // Merge second dataset based on name
      for (const item of associationData.value) {
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
              mergedData[canton].wrestlerActive = item.wrestlerActive;
              mergedData[canton].id = item.id;
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
              mergedData[canton].wrestlerActive = item.wrestlerActive;
              mergedData[canton].id = item.id;
            });
            break;
          }
          case "NWSV": {
            const nwsv = ["Aargau", "Basel-Stadt", "Baselland", "Solothurn"];
            nwsv.forEach((canton) => {
              mergedData[canton].wrestlerActive = item.wrestlerActive;
              mergedData[canton].id = item.id;
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
              mergedData[canton].wrestlerActive = item.wrestlerActive;
              mergedData[canton].id = item.id;
            });
            break;
          }
        }
      }

      // Convert the merged object back to an array if needed
      mergedAssociations.value = Object.values(mergedData);
    });
  await pocketbase
    .collection("wrestlersByCanton")
    .getFullList(50 /* batch size */, {
      sort: "name",
      fields: "id,name,association,wrestlerAmount,wrestlerActive",
    })
    .then((data) => {
      fullCantonData.value = data;

      const mergedData: any = {};

      // Merge first dataset based on name
      for (const item of cantons) {
        if (item.properties) {
          const name = item.properties.name;
          mergedData[name] = { ...mergedData[name], ...item };
        }
      }

      // Merge second dataset based on name
      for (const item of fullCantonData.value) {
        const name = item.name;
        switch (name) {
          case "Berner-Jura":
          case "Emmental":
          case "Mittelland":
          case "Oberaargau":
          case "Oberland":
          case "Seeland":
            if (mergedData.Bern.wrestlerActive) {
              mergedData.Bern.wrestlerActive += item.wrestlerActive;
            } else {
              mergedData.Bern = { ...mergedData.Bern, ...item };
            }
            break;
          case "Ob- und Nidwalden":
            mergedData.Obwalden = { ...mergedData.Obwalden, ...item };
            mergedData.Nidwalden = { ...mergedData.Nidwalden, ...item };
            break;
          case "Appenzell":
            mergedData["Appenzell Ausserrhoden"] = {
              ...mergedData["Appenzell Ausserrhoden"],
              ...item,
            };
            mergedData["Appenzell Innerrhoden"] = {
              ...mergedData["Appenzell Innerrhoden"],
              ...item,
            };
            break;
          default:
            mergedData[name] = { ...mergedData[name], ...item };
        }
      }

      // Convert the merged object back to an array if needed
      mergedCantons.value = Object.values(mergedData);
    });
  const config = {
    type: "choropleth",
    data: {
      labels: mergedAssociations.value.map((d: any) => d.properties.name),
      datasets: [
        {
          label: "Teilverbände",
          outline: nation,
          showOutline: true,
          data: mergedAssociations.value.map((d: any) => ({
            feature: d,
            value: d.wrestlerActive,
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
            return v.feature.properties.name + ": " + v.feature.wrestlerActive;
          },
          display: function (context: any) {
            return context.active;
          },
        },
      },
      onClick: (evt: any) => {
        const res = chart.value.getElementsAtEventForMode(
          evt,
          "nearest",
          { intersect: true },
          true,
        );
        if (res.length !== 0) {
          const route =
            "/associations/association/" + res[0].element.feature.id;
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
  const canvasData = document.getElementById("canvasData") as HTMLCanvasElement;
  const ctxData = canvasData.getContext("2d");
  if (!ctxData || !(ctxData instanceof CanvasRenderingContext2D)) {
    navigateTo("/error");
  } else {
    chart.value = new Chart(ctxData, config as any);
  }
  loadingData.value = false;
});

const onTabOpen = (event: { index: string | number }) => {
  currentAssociation.value = associationData.value[event.index].id;
  currentSelection.value = "Kanton";
  chart.value.data.labels = mergedCantons.value.map(
    (d: any) => d.properties.name,
  );
  chart.value.data.datasets[0].label = "Kantone";
  chart.value.data.datasets[0].data = mergedCantons.value.map((d: any) => ({
    feature: d,
    value: d.wrestlerActive,
  }));
  chart.value.options.onClick = (evt: any) => {
    const res = chart.value.getElementsAtEventForMode(
      evt,
      "nearest",
      { intersect: true },
      true,
    );
    if (res.length !== 0) {
      let route: string;
      if (res[0].element.feature.properties.name === "Bern") {
        route =
          "/associations/association/" + res[0].element.feature.association;
      } else {
        route = "/associations/canton/" + res[0].element.feature.id;
      }
      navigateTo(route);
    }
  };
  chart.value.update();
};

const onTabClose = () => {
  currentSelection.value = "Teilverband";
  chart.value.data.labels = mergedAssociations.value.map(
    (d: any) => d.properties.name,
  );
  chart.value.data.datasets[0].label = "Teilverbände";
  chart.value.data.datasets[0].data = mergedAssociations.value.map(
    (d: any) => ({
      feature: d,
      value: d.wrestlerActive,
    }),
  );
  chart.value.options.onClick = (evt: any) => {
    const res = chart.value.getElementsAtEventForMode(
      evt,
      "nearest",
      { intersect: true },
      true,
    );
    if (res.length !== 0) {
      const route = "/associations/association/" + res[0].element.feature.id;
      navigateTo(route);
    }
  };
  chart.value.update();
};

const onSubTabOpen = async (event: { index: string | number }) => {
  currentCanton.value = fullCantonData.value.filter(
    (canton: any) => canton.association === currentAssociation.value,
  )[event.index];
  await pocketbase
    .collection("wrestlersByClub")
    .getFullList(200 /* batch size */, {
      sort: "name",
      filter: 'canton.id = "' + currentCanton.value.id + '"',
      fields: "id,name,canton,wrestlerAmount,wrestlerActive",
    })
    .then((data) => {
      clubData.value = data;
    });
};

function getCantons(associationId: string) {
  return fullCantonData.value.filter(
    (canton: any) => canton.association === associationId,
  );
}
</script>
<template>
  <div>
    <div class="flex justify-center">
      <div class="h-fit w-screen md:w-4">
        <p class="text-xl font-bold mt-1 md:mt-2 mb-1 md:mb-2 text-center">
          Anzahl Schwinger pro {{ currentSelection }}
        </p>
        <canvas id="canvasData" ref="canvasData"></canvas>
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
