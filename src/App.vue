<template>
  <main>
    <h1>Kcal Tracker</h1>

    <div class="current">
      <span>{{ currentKcal.kcal }}</span>
      <small>Current kcal</small>
    </div>

    <form @submit.prevent="addKcal()">
      <input type="number" step="50" v-model="kcalInput" />
      <input type="submit" value="Add kcal" />
    </form>

    <div v-if="kcals && kcals.length > 0">
      <h2>Last 7 days</h2>

      <div class="canvas-box">
        <canvas ref="kcalChartEl"></canvas>
      </div>

      <div class="kcal-history">
        <h2>Kcal history</h2>
        <ul>
          <li v-for="(kcal, index) in kcals" :key="kcal.date">
            <span>{{ kcal.kcal }}kcal</span>
            <small>{{ new Date(kcal.date).toLocaleDateString() }}</small>
            <button class="delete__button" @click="deleteKcal(index)">
              <img src="./images/trash-outline.svg" class="delete__image" />
            </button>
          </li>
        </ul>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, shallowRef, watch, computed, nextTick, onMounted } from 'vue';
import Chart from 'chart.js/auto';

const kcals = ref(null);

const kcalChartEl = ref(null);

const kcalChart = shallowRef(null);

const kcalInput = ref(1500);

const currentKcal = computed(() => {
  const sortedKcals = kcals.value || [];

  return sortedKcals.sort((a, b) => b.date - a.date)[0] || { kcal: 0 };
});

const data = ref([]);

const addKcal = () => {
  if (kcals.value === null || kcals.value === undefined) {
    kcals.value = [];
  }

  kcals.value.push({
    kcal: kcalInput.value,
    date: new Date().getTime(),
  });
  data.value = kcals.value;
  postData(kcals.value);
};

const deleteKcal = (index) => {
  kcals.value.splice(index, 1);
  data.value = kcals.value;
  postData(kcals.value);
};

async function postData(data) {
  const response = await fetch(
    'https://kcal-track-default-rtdb.europe-west1.firebasedatabase.app/values.json',
    {
      method: 'PUT',
      body: JSON.stringify(data),
    }
  );

  const responseData = await response.json();

  if (!response.ok) {
    const error = new Error(responseData.message || 'Failed to send request');
    throw error;
  }

  data.value = responseData;
}

async function getData() {
  const response = await fetch(
    'https://kcal-track-default-rtdb.europe-west1.firebasedatabase.app/values.json',
    {
      method: 'GET',
      body: JSON.stringify(),
    }
  );

  const responseData = await response.json();

  if (!response.ok) {
    const error = new Error(responseData.message || 'Failed to send request.');
    throw error;
  }

  kcals.value = [];
  data.value = responseData;
  kcals.value = data.value;
}

onMounted(() => {
  getData();
});

watch(
  kcals,
  (newKcals) => {
    if (newKcals !== null && newKcals !== undefined) {
      const kc = newKcals.map((kcal) => ({ ...kcal }));

      nextTick(() => {
        if (kcalChartEl.value) {
          if (kcalChart.value) {
            kcalChart.value.destroy();
          }

          kcalChart.value = new Chart(kcalChartEl.value.getContext('2d'), {
            type: 'line',
            data: {
              labels: kc
                .sort((a, b) => a.date - b.date)
                .map((k) => new Date(k.date).toLocaleDateString())
                .slice(-7),
              datasets: [
                {
                  label: 'kcal',
                  data: kc
                    .sort((a, b) => a.date - b.date)
                    .map((k) => k.kcal)
                    .slice(-7),
                  backgroundColor: 'rgba(255,105,180, 0.2)',
                  borderColor: 'rgb(255,105,180)',
                  borderWidth: 1,
                  fill: true,
                },
              ],
            },
            options: {
              responsive: true,
              maintainAspectRatio: false,
            },
          });
        }
      });
    }
  },
  { deep: true }
);
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: 'montserrat', sans-serif;
}
body {
  background-color: #eee;
}
main {
  padding: 1.5rem;
}
h1 {
  font-size: 2em;
  text-align: center;
  margin-bottom: 2rem;
}
h2 {
  margin-bottom: 1rem;
  color: #888;
  font-weight: 400;
}
.current {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 200px;
  height: 200px;

  text-align: center;
  background-color: white;
  border-radius: 999px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border: 5px solid hwb(330 41% 0%);

  margin: 0 auto 2rem;
}
.current span {
  display: block;
  font-size: 2em;
  font-weight: bold;
  margin-bottom: 0.5rem;
}
.current small {
  color: #888;
  font-style: italic;
}
form {
  display: flex;
  margin-bottom: 2rem;
  border: 1px solid #aaa;
  border-radius: 0.5rem;
  overflow: hidden;
  transition: 200ms linear;
}
form:focus-within,
form:hover {
  border-color: hotpink;
  border-width: 2px;
}
form input[type='number'] {
  appearance: none;
  outline: none;
  border: none;
  background-color: white;
  flex: 1 1 0%;
  padding: 1rem 1.5rem;
  font-size: 1.25rem;
}
form input[type='submit'] {
  appearance: none;
  outline: none;
  border: none;
  cursor: pointer;
  background-color: hotpink;
  padding: 0.5rem 1rem;
  color: white;
  font-size: 1.25rem;
  font-weight: 700;
  transition: 200ms linear;
  border-left: 3px solid transparent;
}
form input[type='submit']:hover {
  background-color: white;
  color: hotpink;
  border-left-color: hotpink;
}
.canvas-box {
  width: 100%;
  max-width: 720px;
  background-color: white;
  padding: 1rem;
  border-radius: 0.5rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  margin: 0 auto 2rem;
}
.kcal-history ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.kcal-history ul li {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.5rem;
}

.kcal-history ul li:nth-child(even) {
  background-color: #dfdfdf;
}
.kcal-history ul li:hover {
  background-color: #f8f8f8;
}
.kcal-history ul li:last-of-type {
  border-bottom: none;
}
.kcal-history ul li span {
  display: block;
  font-size: 1.25rem;
  font-weight: 700;
  margin-right: 1rem;
}
.kcal-history ul li small {
  color: #888;
  font-style: italic;
}

.delete__image {
  width: 20px;
  height: 20px;
}

.delete__button {
  background: none;
  border: none;
  cursor: pointer;
}

.delete__image:hover {
  opacity: 0.5;
}
</style>
