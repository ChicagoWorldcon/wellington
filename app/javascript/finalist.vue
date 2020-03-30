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
  <li class="finalist-component list-group-item">
    <input
      type="text"
      v-model="finalist.rank"
      :class="{ 'text-danger': invalid }"
    >
    <span v-bind:class="{ 'text-danger': invalid }">
      {{ finalist.name }}
    </span>
  </li>
</template>

<script>
export default {
  props: ['finalist', 'ranks'],
  computed: {
    rankSet: (vm) => !!vm.finalist.rank,
    rankInRange: (vm) => {
      const rank = parseInt(vm.finalist.rank, 10);
      return rank >= 1 && rank <= 7;
    },
    rankAlreadySet: (vm) => (
      vm.ranks.filter((rank) => rank === vm.finalist.rank).length > 1
    ),
    ranksSmallToLarge: (vm) => {
      const rank = parseInt(vm.finalist.rank, 10);
      const ranks = vm.ranks.map(r => parseInt(r, 10)).sort();
      return ranks[rank - 1] === rank;
    },
    invalid: (vm) => (
      !vm.valid
    ),
    valid: (vm) => {
      if (!vm.rankSet) {
        return true;
      }
      return !vm.rankAlreadySet && vm.rankInRange && vm.ranksSmallToLarge;
    },
  },
};
</script>

<style>
input {
  width: 25px;
  margin: 0 5px 5px 0;
  text-align: center;
  line-height: 1em;
}
</style>
