<script setup lang="ts">
const pocketbase = usePocketbase();

const route = useRoute();

const wrestlerData = ref();
const rankingsData = ref();
const opponentsData = ref();
const displayOpponent = (opponentsData: { name: string; vorname: string }) =>
  opponentsData.name + " " + opponentsData.vorname;
const selectedOpponent = ref();
const boutsData = ref();
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
      expand: "club,club.canton,club.canton.association",
      fields:
        "id,nummer,name,vorname,year,category,expand.club.name,expand.canton.name,expand.assosiaction.name",
    })
    .then((data) => {
      data.nummer = data.nummer === 0 ? "-" : data.nummer;
      data.year = data.year ? data.year.split("-")[0] : "-";
      data.category = data.category ? data.category : "-";
      wrestlerData.value = data;
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
      expand: "place",
      sort: "-place.year,-created",
      fields:
        "id,rank,points,result,expand.place.id,expand.place.name,expand.place.year",
    })
    .then((data) => {
      data.forEach((item: any) => {
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

const ratioWinDrawLoss = computed({
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
});

async function rowClick(wid: any, pid: any) {
  await navigateTo("/wrestler/" + wid + "-" + pid);
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
        <template #content>
          <p>Nummer: {{ wrestlerData.nummer }}</p>
          <p>Kategorie: {{ wrestlerData.category }}</p>
          <p>Jahrgang: {{ wrestlerData.year }}</p>
          <p>Schwingklub: {{ wrestlerData.expand.club.name }}</p>
          <p v-if="wrestlerData.expand.club.expand.length">
            Gauverband: {{ wrestlerData.expand.club.expand.canton.name }}
          </p>
          <p
            v-if="
              wrestlerData.expand.club.expand.length &&
              wrestlerData.expand.club.expand.canton.expand.length
            "
          >
            Schwingerverband:
            {{ wrestlerData.expand.club.expand.canton.expand.association.name }}
            ({{
              wrestlerData.expand.club.expand.canton.expand.association
                .abbreviation
            }})
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
        <template #title>Statistiken</template>
        <template #content>
          <p class="text-lg md:text-xl text-stone-700 font-bold">Jahr:</p>
          <Dropdown
            v-model="selectedYear"
            :options="years"
            option-label="year"
            placeholder="Wähle ein Jahr"
            class="w-fit mb-2 text-stone-700 font-bold"
            @change="yearSelected()"
          />
          <p>Ø Rang: {{ averageRank }}</p>
          <p>Ø Punkte: {{ averagePoints }}</p>
          <Chart
            v-if="ratioWinDrawLoss"
            type="pie"
            :data="ratioWinDrawLoss"
            :options="chartOptions"
            class="w-full md:w-15rem"
          />
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
            data-key="id"
          >
            <template #list="slotProps">
              <div
                class="col-12 hover:bg-gray-200 cursor-pointer"
                @click="
                  rowClick(route.params.id, slotProps.data.expand.place.id)
                "
              >
                <div class="grid">
                  <div class="col-4 md:col-6">
                    <p class="font-bold">
                      {{ slotProps.data.expand.place.name }}
                    </p>
                  </div>
                  <div v-if="layout === 'default'" class="col-1 md:col-2">
                    <p class="font-bold">
                      {{ slotProps.data.expand.place.year }}
                    </p>
                  </div>
                  <div class="col-1">
                    <p>{{ slotProps.data.rank }}</p>
                  </div>
                  <div class="col-2 md:col-1">
                    <p>{{ slotProps.data.points }}</p>
                  </div>
                  <div class="col-4 md:col-2">
                    <p>{{ slotProps.data.result }}</p>
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
              <div class="col-6">
                <strong> {{ slotProps.data.expand.place.name }}</strong>
              </div>
              <div class="col-2">
                <p>{{ slotProps.data.expand.place.year }}</p>
              </div>
              <div class="col-2">
                <p>{{ slotProps.data.points }}</p>
              </div>
              <div class="col-2">
                <p>{{ slotProps.data.result }}</p>
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
