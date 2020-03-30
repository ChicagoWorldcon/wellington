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
  <div class=category-component>
    <p>{{ category.name }}</p>
    <ul class="list-group list-group-flush text-dark">
      <finalist
        v-for="finalist in category.finalists"
        v-bind:finalist="finalist"
        v-bind:ranks="ranks"
      />
    </ul>
  </div>
</template>

<script>
import Finalist from './finalist.vue'

export default {
  props: ["category"],
  computed: {
    ranks: (vm) => {
      const ranks = vm.category.finalists.map(finalist => finalist.rank)
      const setRanks = ranks.filter(r => !!r)
      return setRanks
    }
  },
  components: { Finalist },
}
</script>

<style scoped>
</style>
