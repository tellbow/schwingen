<script setup lang="ts">
// import { ChartConfiguration } from "chart.js";
import { Chart } from "chart.js";
import { Feature } from "geojson";
import {
  ChoroplethController,
  GeoFeature,
  ColorScale,
  ProjectionScale,
  topojson,
} from "chartjs-chart-geo";
import ChartDataLabels from "chartjs-plugin-datalabels";
import { GeometryCollection, Topology } from "topojson-specification";
import maps from "~/public/topo/swiss-maps-modified.json";

const pocketbase = usePocketbase();

const chartCanton = shallowRef();
const chartAssociation = shallowRef();
const fullCantonData = ref();
const fullAssociationData = ref();
const clubData = ref();
const loadingAssociation = ref(true);

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
      fullAssociationData.value = data;

      const mergedData: any = {};

      // Merge first dataset based on name
      for (const item of cantons) {
        if (item.properties) {
          const name = item.properties.name;
          mergedData[name] = { ...mergedData[name], ...item };
        }
      }

      // Merge second dataset based on name
      for (const item of fullAssociationData.value) {
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
            });
            break;
          }
          case "NWSV": {
            const nwsv = ["Aargau", "Basel-Stadt", "Baselland", "Solothurn"];
            nwsv.forEach((canton) => {
              mergedData[canton].wrestlerActive = item.wrestlerActive;
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
            });
            break;
          }
        }
      }

      // Convert the merged object back to an array if needed
      const mergedArray = Object.values(mergedData);

      const config = {
        type: "choropleth",
        data: {
          labels: mergedArray.map((d: any) => d.properties.name),
          datasets: [
            {
              label: "Teilverbände",
              outline: nation,
              showOutline: true,
              data: mergedArray.map((d: any) => ({
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
                return (
                  v.feature.properties.name + ": " + v.feature.wrestlerActive
                );
              },
              display: function (context: any) {
                return context.active;
              },
            },
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
      const canvasAssociation = document.getElementById(
        "canvasAssociation",
      ) as HTMLCanvasElement;
      const ctxAssociation = canvasAssociation.getContext("2d");
      if (
        !ctxAssociation ||
        !(ctxAssociation instanceof CanvasRenderingContext2D)
      ) {
        navigateTo("/error");
      } else {
        // chart.value = new ChoroplethChart(ctx, config as any);
        chartAssociation.value = new Chart(ctxAssociation, config as any);
      }
      loadingAssociation.value = false;
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
      const mergedArray = Object.values(mergedData);

      const config = {
        type: "choropleth",
        data: {
          labels: mergedArray.map((d: any) => d.properties.name),
          datasets: [
            {
              label: "Kantone",
              outline: nation,
              showOutline: true,
              data: mergedArray.map((d: any) => ({
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
                return (
                  v.feature.properties.name + ": " + v.feature.wrestlerActive
                );
              },
              display: function (context: any) {
                return context.active;
              },
            },
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
      const canvasCanton = document.getElementById(
        "canvasCanton",
      ) as HTMLCanvasElement;
      const ctxCanton = canvasCanton.getContext("2d");
      if (!ctxCanton || !(ctxCanton instanceof CanvasRenderingContext2D)) {
        navigateTo("/error");
      } else {
        // chart.value = new ChoroplethChart(ctx, config as any);
        chartCanton.value = new Chart(ctxCanton, config as any);
      }
    });
});

const onTabOpen = () => {};

const onTabClose = () => {};

const onSubTabOpen = async (event: { index: string | number }) => {
  await pocketbase
    .collection("wrestlersByClub")
    .getFullList(200 /* batch size */, {
      sort: "name",
      filter: 'canton.id = "' + fullCantonData.value[event.index].id + '"',
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
          Anzahl Schwinger pro Teilverband
        </p>
        <canvas id="canvasAssociation" ref="canvasAssociation"></canvas>
        <p class="text-xl font-bold mt-1 md:mt-2 mb-1 md:mb-2 text-center">
          Anzahl Schwinger pro Kanton
        </p>
        <canvas id="canvasCanton" ref="canvasCanton"></canvas>
      </div>
    </div>
    <div
      class="justify-content-center align-content-center display: flex flex-wrap fill-height mt-3 md:mt-6"
    >
      <ProgressSpinner v-if="loadingAssociation" />
      <Accordion
        v-else
        lazy
        class="w-12 sm:w-10 md:w-8 lg:w-6 xl:w-4"
        @tab-click="onTabOpen()"
        @tab-close="onTabClose()"
      >
        <AccordionTab
          v-for="association in fullAssociationData"
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
                    :to="'/clubs/' + value.id"
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
