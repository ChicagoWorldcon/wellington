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
  <div class="category-component l-v-spacing">
    <h2>{{ category.name }}</h2>
    <ul class="list-group list-group-flush text-dark l-v-spacing">
      <finalist
        v-for="finalist in category.finalists"
        :key="finalist.id"
        :finalist="finalist"
        :disabled="dirty"
        :ranks="ranks"
      />
    </ul>
    <button
      v-on:click="save(category)"
      v-bind:key="category.id"
      v-bind:disabled="!dirty"
      class="btn"
    >Vote for {{ category.name }}</button>
  </div>
</template>

<script>
import Finalist from "./finalist.vue";

export default {
  props: ["category"],
  data() {
    return {
      dirty: false
    };
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
  updated() {
    this.dirty = true;
  },
  methods: {
    save: category => {
      fetch("", {
        body: JSON.stringify({ category }),
        method: "PUT",
        headers: { "Content-Type": "application/json" }
      }).then(() => {
        // Work around mutating arguements "no-param-reassign"
        const categoryRef = category;
        categoryRef.dirty = false;
      });
    }
  }
};
</script>

<style scoped>
</style>
