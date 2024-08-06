<script setup lang="ts">
import Chart from "primevue/chart";

const pocketbase = usePocketbase();

const route = useRoute();

const wrestlerData = ref();
const eloData = ref();
const rankingsData = ref();
const opponentsData = ref();
const displayOpponent = (opponentsData: { name: string; vorname: string }) =>
  opponentsData.name + " " + opponentsData.vorname;
const selectedOpponent = ref();
const boutsData = ref();
const wreath1 = ref(0);
const wreath2 = ref(0);
const wreath3 = ref(0);
const ratioWinDrawLoss = ref();
const graphWinDrawLoss = ref();
const loadingWrestler = ref(true);
const loadingRankings = ref(true);
const loadingOpponents = ref(true);
const loadingBouts = ref(false);
const selectedYear = ref({ year: "Alle" });
const years = ref([
  // { year: 1998 },
  // { year: 2000 },
  // { year: 2001 },
  // { year: 2002 },
  // { year: 2003 },
  // { year: 2004 },
  // { year: 2005 },
  // { year: 2006 },
  // { year: 2007 },
  // { year: 2008 },
  // { year: 2009 },
  // { year: 2010 },
  // { year: 2011 },
  // { year: 2012 },
  // { year: 2013 },
  // { year: 2014 },
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
  { year: "Alle" },
]);

const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";

onMounted(async () => {
  await pocketbase
    .collection("wrestler")
    .getFirstListItem('id="' + route.params.id + '"', {
      expand: "status,club,club.canton,club.canton.association",
      fields:
        "id,name,vorname,year,category,expand.status.status,expand.club.name,expand.club.expand.canton.name,expand.club.expand.canton.expand.association.name,expand.club.expand.canton.expand.association.abbreviation",
    })
    .then((data) => {
      data.year = data.year ? data.year.split("-")[0] : "-";
      wrestlerData.value = data;
    });
  await pocketbase
    .collection("elo")
    .getFirstListItem('wrestler.id="' + route.params.id + '"', {
      fields: "id,rating",
    })
    .then((data) => {
      eloData.value = data;
      loadingWrestler.value = false;
    });
  await loadRankingsData();
  await loadBoutsData();
});

const loadBoutsData = async () => {
  let customFilter;
  if (selectedYear.value.year === "Alle") {
    customFilter = 'wrestler.id = "' + route.params.id + '"';
  } else {
    customFilter =
      'wrestler.id = "' +
      route.params.id +
      '" && place.year ~ "' +
      selectedYear.value.year +
      '"';
  }
  await pocketbase
    .collection("bouts")
    .getFullList(200 /* batch size */, {
      filter: customFilter,
      expand: "opponent",
      sort: "opponent.name,-created",
      fields:
        "id,expand.opponent.id,expand.opponent.name,expand.opponent.vorname",
    })
    .then((data) => {
      opponentsData.value = Array.from(
        new Map(
          data.map((obj: { expand: any }) => [
            obj.expand.opponent.id,
            {
              id: obj.expand.opponent.id,
              name: obj.expand.opponent.name,
              vorname: obj.expand.opponent.vorname,
            },
          ]),
        ).values(),
      );
      loadingOpponents.value = false;
    });
};

const loadRankingsData = async () => {
  let customFilter;
  if (selectedYear.value.year === "Alle") {
    customFilter = 'wrestler.id = "' + route.params.id + '"';
  } else {
    customFilter =
      'wrestler.id = "' +
      route.params.id +
      '" && place.year ~ "' +
      selectedYear.value.year +
      '"';
  }
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      filter: customFilter,
      expand: "place,place.placeType",
      sort: "-place.year,-created",
      fields:
        "id,rank,rank2,points,final,result,wreath,status,expand.place.id,expand.place.name,expand.place.year,expand.place.expand.placeType.type",
    })
    .then((data) => {
      data.forEach((item: any) => {
        if (item.wreath) {
          switch (item.expand.place.expand.placeType.type) {
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
        item.expand.place.year = item.expand.place.year.split("-")[0];
      });
      rankingsData.value = data;
      loadingRankings.value = false;
    });
};

const averageRank = computed({
  get: () => {
    const ar = (
      rankingsData.value
        .map((item: { rank: string }) => item.rank.replace(/\D/g, ""))
        .reduce((a: number, b: string) => a + parseInt(b), 0) /
      rankingsData.value.length
    ).toFixed(2);
    if (isNaN(parseFloat(ar))) {
      return "-";
    } else {
      return ar;
    }
  },
  set: () => {},
});

const averagePoints = computed({
  get: () => {
    const ap = (
      rankingsData.value
        .map((item: { points: string }) => item.points)
        .reduce((a: number, b: string) => a + parseInt(b), 0) /
      rankingsData.value.length
    ).toFixed(2);
    if (isNaN(parseFloat(ap))) {
      return "-";
    } else {
      return ap;
    }
  },
  set: () => {},
});

ratioWinDrawLoss.value = computed({
  get: () => {
    const documentStyle = getComputedStyle(document.body);
    const countsArray = rankingsData.value.reduce(
      (
        accumulator: { win: number; draw: number; loss: number },
        { result }: any,
      ) => {
        const win = result.split("+").length - 1;
        const draw = result.split("-").length - 1;
        const loss = result.split("o").length - 1;
        return {
          win: accumulator.win + win,
          draw: accumulator.draw + draw,
          loss: accumulator.loss + loss,
        };
      },
      { win: 0, draw: 0, loss: 0 },
    );
    if (Object.keys(rankingsData.value).length !== 0) {
      return {
        labels: ["Sieg", "Gestellt", "Niederlage"],
        datasets: [
          {
            data: Object.values(countsArray),
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
    } else {
      return null;
    }
  },
  set: () => {},
});

graphWinDrawLoss.value = computed({
  get: () => {
    const documentStyle = getComputedStyle(document.body);
    const graphArray = rankingsData.value.reduce(
      (
        accumulator: {
          [year: string]: {
            win: number;
            draw: number;
            loss: number;
            total: number;
            winPercentage?: number;
            drawPercentage?: number;
            lossPercentage?: number;
          };
        },
        { result, expand }: any,
      ) => {
        const year = expand.place.year;
        const win = (result.match(/\+/g) || []).length;
        const draw = (result.match(/-/g) || []).length;
        const loss = (result.match(/o/g) || []).length;

        if (!accumulator[year]) {
          accumulator[year] = { win: 0, draw: 0, loss: 0, total: 0 };
        }

        accumulator[year].win += win;
        accumulator[year].draw += draw;
        accumulator[year].loss += loss;
        accumulator[year].total += win + draw + loss;
        return accumulator;
      },
      {},
    );
    Object.keys(graphArray).forEach((year) => {
      const yearData = graphArray[year];
      yearData.winPercentage = (yearData.win / yearData.total) * 100;
      yearData.drawPercentage = (yearData.draw / yearData.total) * 100;
      yearData.lossPercentage = (yearData.loss / yearData.total) * 100;
    });
    if (Object.keys(rankingsData.value).length !== 0) {
      return {
        labels: Object.keys(graphArray),
        datasets: [
          {
            label: "Sieg",
            data: Object.values(graphArray).map((object: any) => ({
              winPercentage: object.winPercentage,
              win: object.win,
            })),
            parsing: {
              xAxisKey: "win",
              yAxisKey: "winPercentage",
            },
            backgroundColor: [documentStyle.getPropertyValue("--green-500")],
            hoverBackgroundColor: [
              documentStyle.getPropertyValue("--green-400"),
            ],
          },
          {
            label: "Gestellt",
            data: Object.values(graphArray).map((object: any) => ({
              drawPercentage: object.drawPercentage,
              draw: object.draw,
            })),
            parsing: {
              xAxisKey: "draw",
              yAxisKey: "drawPercentage",
            },
            backgroundColor: [documentStyle.getPropertyValue("--yellow-500")],
            hoverBackgroundColor: [
              documentStyle.getPropertyValue("--yellow-400"),
            ],
          },
          {
            label: "Niederlage",
            data: Object.values(graphArray).map((object: any) => ({
              lossPercentage: object.lossPercentage,
              loss: object.loss,
            })),
            parsing: {
              xAxisKey: "loss",
              yAxisKey: "lossPercentage",
            },
            backgroundColor: [documentStyle.getPropertyValue("--red-500")],
            hoverBackgroundColor: [documentStyle.getPropertyValue("--red-400")],
          },
        ],
      };
    } else {
      return null;
    }
  },
  set: () => {},
});

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

const addLabel = (tooltipItems: any) => {
  let amount;

  if ("win" in tooltipItems.raw) {
    amount = tooltipItems.raw.win;
  } else if ("draw" in tooltipItems.raw) {
    amount = tooltipItems.raw.draw;
  } else if ("loss" in tooltipItems.raw) {
    amount = tooltipItems.raw.loss;
  } else {
    amount = "0";
  }
  return "Anzahl: " + amount;
};

const addHeader = (tooltipItems: any) => {
  let amount;

  if ("winPercentage" in tooltipItems[0].raw) {
    amount = tooltipItems[0].raw.winPercentage.toFixed(0);
  } else if ("drawPercentage" in tooltipItems[0].raw) {
    amount = tooltipItems[0].raw.drawPercentage.toFixed(0);
  } else if ("lossPercentage" in tooltipItems[0].raw) {
    amount = tooltipItems[0].raw.lossPercentage.toFixed(0);
  } else {
    amount = "0";
  }
  return "Prozent: " + amount + "%";
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

async function wrestlerRowClick(wid: any, pid: any) {
  await navigateTo("/wrestler/" + wid + "-" + pid);
}

async function placeRowClick(pid: any) {
  await navigateTo("/rankings/" + pid);
}

const findBouts = () => {
  loadingBouts.value = true;
  pocketbase
    .collection("bouts")
    .getFullList(200 /* batch size */, {
      filter:
        'wrestler.id = "' +
        route.params.id +
        '" && opponent.id = "' +
        selectedOpponent.value +
        '"',
      expand: "place",
      sort: "-place.year,-created",
      fields:
        "id,result,points,expand.place.id,expand.place.name,expand.place.year",
    })
    .then((data) => {
      data.forEach((item: { expand: any }) => {
        item.expand.place.year = item.expand.place.year.split("-")[0];
      });
      boutsData.value = data;
      loadingBouts.value = false;
    });
};

async function yearSelected() {
  await loadRankingsData();
  await loadBoutsData();
}
</script>
<template>
  <div>
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
        v-if="ratioWinDrawLoss.value"
        class="w-11/12 md:w-9/12 lg:w-22rem mt-2 md:mr-2"
      >
        <template #title>Statistiken</template>
        <template #content>
          <p>Ø Rang: {{ averageRank }}</p>
          <p>Ø Punkte: {{ averagePoints }}</p>
          <div class="relative w-full md:max-w-80 md:min-w-80">
            <Chart
              type="pie"
              :data="ratioWinDrawLoss.value"
              :options="chartOptions"
            />
          </div>
        </template>
      </Card>
      <Card
        v-if="graphWinDrawLoss.value"
        class="w-11/12 md:w-7/12 mt-2 md:mr-2"
      >
        <template #title />
        <template #content>
          <div>
            <Chart
              type="line"
              :data="graphWinDrawLoss.value"
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
                <p class="col-4 md:col-2">Resultat</p>
                <p v-if="layout === 'default'" class="md:col-1">Schlussgang</p>
                <p v-if="layout === 'default'" class="md:col-1">
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
                    wrestlerRowClick(route.params.id, item.expand.place.id)
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
                    <div class="col-4 md:col-2">
                      <p>{{ item.result }}</p>
                    </div>
                    <div v-if="layout === 'default'" class="md:col-1">
                      <Icon v-if="item.final" name="gis:flag-finish" />
                    </div>
                    <div v-if="layout === 'default'" class="md:col-1">
                      <Icon v-if="item.wreath" name="mingcute:wreath-fill" />
                      <Icon
                        v-if="item.status === 'Unfall'"
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
