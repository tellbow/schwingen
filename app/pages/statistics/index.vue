<script setup lang="ts">
// Set SEO metadata for the statistics page
useSeo({
  title: "Statistiken - Tellbow",
  description:
    "Detaillierte Statistiken und Analysen zu Schweizer Schwingern. ELO-Ratings, Durchschnittsranglisten, Siege, Kränze und mehr.",
  keywords:
    "Schwingen Statistiken, ELO Rating, Durchschnittsrang, Siege, Kränze, Schweizer Schwinger, ESV",
});

// Types
interface YearOption {
  year: string | number;
}

interface EloData {
  id: string;
  rating: number;
  expand: {
    wrestler: {
      id: string;
      name: string;
      vorname: string;
    };
  };
}

interface AverageRankData {
  id: string;
  wid: string;
  name: string;
  vorname: string;
  year: string;
  averageRank: number;
  avgRank?: number;
}

interface AveragePointsData {
  id: string;
  wid: string;
  name: string;
  vorname: string;
  year: string;
  averagePoints: number;
  avgPoints?: number;
}

interface MostWinsData {
  id: string;
  name: string;
  vorname: string;
  wins: number;
  wreath: number;
}

interface MostPlacesAttendedData {
  id: string;
  name: string;
  vorname: string;
  year: string;
  placesAttended: number;
}

interface MostWreathsData {
  id: string;
  name: string;
  vorname: string;
  wreath: number;
}

interface DrawDecisionRatioData {
  countDraw: number;
  countAll: number;
  yearFormat: string;
}

// Composables
const pocketbase = usePocketbase();

// Reactive state
const op = ref();
const op2 = ref();
const loadingElo = ref(true);
const eloData = ref<EloData[]>([]);
const loadingAverageRank = ref(true);
const averageRank = ref<AverageRankData[]>([]);
const loadingAveragePoints = ref(true);
const averagePoints = ref<AveragePointsData[]>([]);
const loadingMostWins = ref(true);
const mostWins = ref<MostWinsData[]>([]);
const loadingMostPlacesAttended = ref(true);
const mostPlacesAttended = ref<MostPlacesAttendedData[]>([]);
const loadingMostWreaths = ref(true);
const mostWreaths = ref<MostWreathsData[]>([]);
const loadingDrawDecisionRatio = ref(true);
const drawDecisionRatio = ref<number>(0);

// Year selection
const selectedYear = ref<YearOption>({ year: "Alle" });
const years: YearOption[] = [
  { year: 2015 },
  { year: 2016 },
  { year: 2017 },
  { year: 2018 },
  { year: 2019 },
  { year: 2021 },
  { year: 2022 },
  { year: 2023 },
  { year: 2024 },
  { year: 2025 },
  { year: "Alle" },
];

// Methods
const toggle = (event: Event): void => {
  op.value.toggle(event);
};

const toggle2 = (event: Event): void => {
  op2.value.toggle(event);
};

const loadData = async (): Promise<void> => {
  try {
    let loadYear: string;
    let yearFormatFilter: string;

    if (selectedYear.value.year === "Alle") {
      loadYear = "Overall";
      yearFormatFilter = "%";
    } else {
      loadYear = selectedYear.value.year.toString();
      yearFormatFilter = selectedYear.value.year.toString();
    }

    // Load ELO data
    const eloResponse = await pocketbase.collection("elo").getList(1, 5, {
      expand: "wrestler",
      sort: "-rating,-created",
      fields:
        "id,rating,expand.wrestler.id,expand.wrestler.name,expand.wrestler.vorname",
    });
    eloData.value = eloResponse.items;
    loadingElo.value = false;

    // Load average rank data
    const averageRankResponse = await pocketbase
      .collection("averageRank" + loadYear)
      .getList(1, 5, {
        fields: "averageRank,wid,name,vorname,year",
      });
    averageRankResponse.items.forEach((item: AverageRankData) => {
      item.avgRank = Math.round(item.averageRank * 100) / 100;
    });
    averageRank.value = averageRankResponse.items;
    loadingAverageRank.value = false;

    // Load average points data
    const averagePointsResponse = await pocketbase
      .collection("averagePoints" + loadYear)
      .getList(1, 5, {
        fields: "averagePoints,wid,name,vorname,year",
      });
    averagePointsResponse.items.forEach((item: AveragePointsData) => {
      item.avgPoints = Math.round(item.averagePoints * 100) / 100;
    });
    averagePoints.value = averagePointsResponse.items;
    loadingAveragePoints.value = false;

    // Load most wins data
    const mostWinsResponse = await pocketbase
      .collection("mostWins" + loadYear)
      .getList(1, 5, {
        sort: "-wins,-wreath",
        fields: "wins,wreath,id,name,vorname",
      });
    mostWins.value = mostWinsResponse.items;
    loadingMostWins.value = false;

    // Load most places attended data
    const mostPlacesAttendedResponse = await pocketbase
      .collection("mostPlacesAttended" + loadYear)
      .getList(1, 5, {
        fields: "placesAttended,id,name,vorname,year",
      });
    mostPlacesAttended.value = mostPlacesAttendedResponse.items;
    loadingMostPlacesAttended.value = false;

    // Load most wreaths data
    const mostWreathsResponse = await pocketbase
      .collection("mostWreaths" + loadYear)
      .getList(1, 5, {
        fields: "wreath,id,name,vorname",
      });
    mostWreaths.value = mostWreathsResponse.items;
    loadingMostWreaths.value = false;

    // Load draw decision ratio data
    const drawDecisionRatioResponse = await pocketbase
      .collection("drawDecisionRatio")
      .getList(1, 24, {
        filter: `yearFormat ~ '${yearFormatFilter}'`,
        fields: "countDraw,countAll,yearFormat",
      });

    let sumAll = 0;
    let sumDraw = 0;
    drawDecisionRatioResponse.items.forEach((item: DrawDecisionRatioData) => {
      sumDraw += item.countDraw;
      sumAll += item.countAll;
    });
    drawDecisionRatio.value =
      sumAll > 0 ? Math.round((sumDraw / sumAll) * 100) : 0;
    loadingDrawDecisionRatio.value = false;
  } catch (error) {
    console.error("Error loading statistics data:", error);
    // Reset loading states on error
    loadingElo.value = false;
    loadingAverageRank.value = false;
    loadingAveragePoints.value = false;
    loadingMostWins.value = false;
    loadingMostPlacesAttended.value = false;
    loadingMostWreaths.value = false;
    loadingDrawDecisionRatio.value = false;
  }
};

const yearSelected = async (): Promise<void> => {
  await loadData();
};

const rowClick = async (wid: string): Promise<void> => {
  try {
    await navigateTo(`/wrestler/${wid}`);
  } catch (error) {
    console.error("Navigation error:", error);
  }
};

// Lifecycle
onMounted(async () => {
  await loadData();
});
</script>
<template>
  <div class="card">
    <div class="flex items-center justify-center mt-2 md:mt-4">
      <p class="ml-2 md:ml-4 text-lg md:text-xl text-stone-700 font-bold">
        Jahr:
      </p>
      <Dropdown
        v-model="selectedYear"
        :options="years"
        option-label="year"
        placeholder="Wähle ein Jahr"
        class="w-fit ml-4 text-stone-700 font-bold"
        @change="yearSelected()"
      />
    </div>
    <div
      class="justify-center flex md:align-items-center align-items-stretch flex-wrap"
    >
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title>
          Top 5 - Elo-Rating
          <Badge value="?" @click="toggle2" />
          <OverlayPanel ref="op2">Jeweils vom aktuellen Jahr</OverlayPanel>
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingElo" />
          <DataView
            v-else
            :value="eloData"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-8 md:col-6">Schwinger</p>
                <p class="col-1 md:col-1">Rating</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.expand.wrestler.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-8 md:col-6">
                      <p>
                        {{ item.expand.wrestler.name }}
                        {{ item.expand.wrestler.vorname }}
                      </p>
                    </div>
                    <div class="col-1 md:col-1">
                      <p>{{ item.rating }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title>
          Top 5 - ⌀ Rang
          <Badge value="?" @click="toggle" />
          <OverlayPanel ref="op">5 Teilnahmen pro Jahr oder mehr</OverlayPanel>
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingAverageRank" />
          <DataView
            v-else
            :value="averageRank"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-8 md:col-6">Schwinger</p>
                <p class="col-1 md:col-1">Rang</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.wid)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-8 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-1 md:col-1">
                      <p>{{ item.avgRank }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title>
          Top 5 - ⌀ Punkte
          <Badge value="?" @click="toggle" />
          <OverlayPanel ref="op">5 Teilnahmen pro Jahr oder mehr</OverlayPanel>
        </template>
        <template #content>
          <ProgressSpinner v-if="loadingAveragePoints" />
          <DataView
            v-else
            :value="averagePoints"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-8 md:col-6">Schwinger</p>
                <p class="col-1 md:col-1">Punkte</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.wid)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-8 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-1 md:col-1">
                      <p>{{ item.avgPoints }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Top 5 - meiste Siege </template>
        <template #content>
          <ProgressSpinner v-if="loadingMostWins" />
          <DataView
            v-else
            :value="mostWins"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-6 md:col-6">Schwinger</p>
                <p class="col-2 md:col-1">Siege</p>
                <p class="col-3 md:col-3">mit Kranz</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-6 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.wins }}</p>
                    </div>
                    <div class="col-3 md:col-3">
                      <p>{{ item.wreath }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Top 5 - meiste Kränze </template>
        <template #content>
          <ProgressSpinner v-if="loadingMostWreaths" />
          <DataView
            v-else
            :value="mostWreaths"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-7 md:col-6">Schwinger</p>
                <p class="col-2 md:col-1">Kränze</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-7 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.wreath }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card
        class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 md:w-5/12"
        :pt="{
          body: { class: 'pt-2 md:pt-3 pb-2 md:pb-3' },
          content: { class: 'p-1 md:p-2' },
        }"
      >
        <template #title> Top 5 - meiste Teilnahmen </template>
        <template #content>
          <ProgressSpinner v-if="loadingMostPlacesAttended" />
          <DataView
            v-else
            :value="mostPlacesAttended"
            data-key="id"
            :pt="{
              header: { class: 'p-0' },
            }"
          >
            <template #header>
              <div class="grid mt-0">
                <p class="col-1 md:col-1 flex justify-center items-center">#</p>
                <p class="col-7 md:col-6">Schwinger</p>
                <p class="col-2 md:col-1">Teilnahmen</p>
              </div>
            </template>
            <template #list="slotProps">
              <div class="grid grid-nogutter">
                <div
                  v-for="(item, index) in slotProps.items"
                  :key="index"
                  class="col-12 hover:bg-gray-200 cursor-pointer"
                  @click="rowClick(item.id)"
                >
                  <div class="grid">
                    <div
                      class="col-1 md:col-1 flex justify-center items-center"
                    >
                      <p>{{ index + 1 }}</p>
                    </div>
                    <div class="col-7 md:col-6">
                      <p>{{ item.name }} {{ item.vorname }}</p>
                    </div>
                    <div class="col-2 md:col-1">
                      <p>{{ item.placesAttended }}</p>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </DataView>
        </template>
      </Card>
      <Card class="ml-2 md:ml-4 mt-2 md:mt-2 mr-2 md:mr-4 w-screen md:w-5">
        <template #title> % Gestellte Gänge </template>
        <template #content>
          <ProgressSpinner v-if="loadingDrawDecisionRatio" />
          <ul v-else>
            <p>{{ drawDecisionRatio }}</p>
          </ul>
        </template>
      </Card>
    </div>
  </div>
</template>
