// Copyright 2020 Matthew B. Gray
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

<template>
  <div class="category-component">
    <p>{{ category.name }}</p>
    <ul class="list-group list-group-flush text-dark">
      <finalist
        v-for="finalist in category.finalists"
        :key="finalist.id"
        :finalist="finalist"
        :ranks="ranks"
      />
    </ul>
    <button
      v-on:click="save(category)"
      v-bind:key="category.id"
      :disabled="saved"
      class="btn"
    >Vote for {{ category.name }}</button>
  </div>
</template>

<script>
import Finalist from "./finalist.vue";

export default {
  props: ["category"],
  data: {
    saved: true,
  },
  computed: {
    ranks: ({ category }) => {
      const ranks = category.finalists.map(finalist => finalist.rank);
      return ranks
        .filter(r => !!r)
        .map(r => parseInt(r, 10))
        .sort();
    }
  },
  components: { Finalist },
  mounted() {
    fetch("categories")
      .then(response => response.json())
      .then(data => {
        this.category = data;
      });
    this.saved = true;
  },
  updated() {
    this.saved = false;
  },
  methods: {
    save: category => {
      fetch("", {
        body: JSON.stringify({ category: category }),
        method: "PUT",
        headers: { "Content-Type": "application/json" }
      }).then(() => {
        console.log('save complete')
      });
      this.saved = true;
    }
  }
};
</script>

<style scoped>
</style>
