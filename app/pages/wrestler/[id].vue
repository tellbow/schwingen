<script setup lang="ts">
const pocketbase = usePocketbase();

const route = useRoute();

const wrestlerData = ref();
const rankingsData = ref();
const loadingWrestler = ref(true);
const loadingRankings = ref(true);

onMounted(async () => {
  await pocketbase
    .collection("wrestler")
    .getFirstListItem('id="' + route.params.id + '"', {
      expand: "club,club.canton,club.canton.association",
    })
    .then((data) => {
      data.year = data.year.split("-")[0];
      wrestlerData.value = data;
      loadingWrestler.value = false;
    });
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      filter: 'wrestler.id = "' + route.params.id + '"',
      expand: "place",
      sort: "-created",
    })
    .then((data) => {
      rankingsData.value = data;
      loadingRankings.value = false;
    });
});

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
        { result }: any
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
      { win: 0, draw: 0, loss: 0 }
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
  plugins: {
    legend: {
      labels: {
        usePointStyle: true,
      },
    },
  },
});

async function rowClick(id: any) {
  await navigateTo("/rankings/" + id);
}
</script>
<template>
  <div>
    <ProgressSpinner v-if="loadingWrestler" />
    <div
      v-else
      class="justify-content-center align-content-center display: flex mt-2"
    >
      <Card class="w-9/12">
        <template #title>
          {{ wrestlerData.vorname }} {{ wrestlerData.name }}
        </template>
        <template #content>
          <p>Nummer: {{ wrestlerData.nummer }}</p>
          <p>Kategorie: {{ wrestlerData.category }}</p>
          <p>Jahrgang: {{ wrestlerData.year }}</p>
          <p>Schwingklub: {{ wrestlerData.expand.club.name }}</p>
          <p>Gauverband: {{ wrestlerData.expand.club.expand.canton.name }}</p>
          <p>
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
      <Card class="w-9/12">
        <template #title>Statistiken</template>
        <template #content>
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
      <Card class="w-9/12">
        <template #title>Resultate</template>
        <template #content>
          <DataView
            v-if="Object.keys(rankingsData).length !== 0"
            :value="rankingsData"
            data-key="id"
          >
            <template #list="slotProps">
              <div
                class="col-7 hover:bg-gray-200 cursor-pointer"
                @click="rowClick(slotProps.data.expand.place.id)"
              >
                <div
                  class="flex flex-column xl:flex-row xl:align-items-start p-1 gap-4"
                >
                  <div class="flex-1">
                    <p class="font-bold">
                      {{ slotProps.data.expand.place.name }}
                    </p>
                  </div>
                  <div
                    class="flex flex-column sm:flex-row justify-content-between align-items-center xl:align-items-start flex-1 gap-4"
                  >
                    <div
                      class="flex flex-column align-items-center sm:align-items-start"
                    >
                      <p>{{ slotProps.data.rank }}</p>
                      <p>{{ slotProps.data.points }}</p>
                      <p>{{ slotProps.data.result }}</p>
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
  </div>
</template>
