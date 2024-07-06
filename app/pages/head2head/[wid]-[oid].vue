<script setup lang="ts">
interface Wrestler {
  name: string;
  vorname: string;
}

interface Place {
  name: string;
  year: string;
}

interface Expand {
  place: Place;
  wrestler: Wrestler;
}

interface DataEntry {
  expand: Expand;
  final: boolean;
  id: string;
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

const pocketbase = usePocketbase();

const route = useRoute();

const op = ref();
const statisticsData = ref();
const comparsionData = ref();
const boutsData = ref();
const loadingStatistics = ref(false);
const loadingBouts = ref(false);

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const layout =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent,
  )
    ? "mobile"
    : "default";

onMounted(async () => {
  await loadStatisticsData();
  await loadBoutsData();
});

const toggle = (event: any) => {
  op.value.toggle(event);
};

const loadStatisticsData = async () => {
  const customFilter =
    '((wrestler.id = "' +
    route.params.wid +
    '") || (wrestler.id = "' +
    route.params.oid +
    '")) && (status != "Unfall" && points <= 60)';
  await pocketbase
    .collection("rankings")
    .getFullList(200 /* batch size */, {
      filter: customFilter,
      expand: "wrestler,place",
      sort: "-place.year,-created",
      fields:
        "id,rank,rank2,points,final,result,wreath,status,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname,expand.place.name,expand.place.year",
    })
    .then((data) => {
      // Grouping data by wrestler name and vorname
      const groupedData: { [key: string]: DataEntry[] } = data.reduce(
        (acc: GroupedData, curr: any) => {
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
        const averageRank = (
          value
            .filter(({ result }) => result.length > 4)
            .reduce((sum, entry) => sum + parseInt(entry.rank), 0) /
          value.length
        ).toFixed(2);
        const averagePoints = (
          value
            .filter(({ result }) => result.length > 4)
            .reduce((sum, entry) => sum + parseFloat(entry.points), 0) /
          value.length
        ).toFixed(2);
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
      const groupedByWrestler: any = {};

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
        const counts: any = {};

        wrestler.bubbles.forEach((entry: any) => {
          if (entry.result.length > 4) {
            const points = parseFloat(entry.points);
            const rank = parseInt(entry.rank);
            const key = `${points},${rank}`;
            if (counts[key]) {
              counts[key]++;
            } else {
              counts[key] = 1;
            }
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
            label: output[0].name + " " + output[0].vorname,
            data: output[0].bubbles,
            backgroundColor: "rgba(255, 99, 132, 0.5)",
            borderColor: "rgba(255, 99, 132, 0.9)",
          },
          {
            label: output[1].name + " " + output[1].vorname,
            data: output[1].bubbles,
            backgroundColor: "rgba(0, 99, 132, 0.5)",
            borderColor: "rgba(0, 99, 132, 0.9)",
          },
        ],
      };
    });
};

const loadBoutsData = async () => {
  const customFilter =
    '(wrestler.id = "' +
    route.params.wid +
    '" && opponent.id ~ "' +
    route.params.oid +
    '") || (wrestler.id = "' +
    route.params.oid +
    '" && opponent.id ~ "' +
    route.params.wid +
    '")';
  await pocketbase
    .collection("bouts")
    .getFullList(200 /* batch size */, {
      filter: customFilter,
      expand: "wrestler,opponent,place",
      sort: "-place.year,-created",
      fields:
        "id,result,points,expand.wrestler.name,expand.wrestler.vorname,expand.opponent.name,expand.opponent.vorname,expand.place.id,expand.place.name,expand.place.year",
    })
    .then((data) => {
      const groupedData: any = {};
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
        const key = `${placeId}-${placeName}-${year}`;
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
    });
};

function isHigher(stat: any, type: string, _reverse = false) {
  // Find the entry with the highest value
  const highest = statisticsData.value.reduce(
    (acc: { [x: string]: string }, curr: { [x: string]: string }) => {
      return parseFloat(curr[type]) > parseFloat(acc[type]) ? curr : acc;
    },
  );
  // Compare current entry with the highest
  if (_reverse) {
    return !(stat === highest[type]);
  }
  return stat === highest[type];
}

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

async function rowRClick(rid: any) {
  await navigateTo("/rankings/" + rid);
}

async function rowWClick(wid: any) {
  await navigateTo("/wrestler/" + wid);
}
</script>
<template>
  <div>
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
              Keine Aufeinandertreffen dieser Schwingern.
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
                      <div v-if="item.entries[0].result === '+'">
                        <Icon name="mdi:crown" />
                        <b>{{ item.entries[0].points }}</b>
                      </div>
                      <p v-else>
                        {{ item.entries[0].points }}
                      </p>
                    </div>
                    <div class="col md:col text-center">
                      <div v-if="item.entries[1].result === '+'">
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
