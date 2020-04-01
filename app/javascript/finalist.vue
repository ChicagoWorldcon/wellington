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
    <div>
      <input
        type="text"
        v-model.number="finalist.rank"
        :class="{ 'text-danger': invalid }"
      >
      <span v-bind:class="{ 'text-danger': invalid }">
        {{ finalist.name }}
      </span>
    </div>

    <p v-for="error in errors" :key="error">
      {{ error }}
    </p>
  </li>
</template>

<script>
export default {
  props: ['finalist', 'ranks'],
  computed: {
    rankSet: (vm) => !!vm.finalist.rank,
    rankInRange: ({ finalist }) => (
      finalist.rank >= 1 && finalist.rank <= 7
    ),
    rankAlreadySet: ({ finalist, ranks }) => {
      const matching = ranks.filter((rank) => rank === finalist.rank);
      return matching.length > 1;
    },
    ranksSmallToLarge: ({ finalist, ranks }) => {
      const expectedOffset = finalist.rank - 1;
      return ranks[expectedOffset] === finalist.rank;
    },
    // TODO check out validation options in vue's model
    // https://vuejs.org/v2/api/#model
    invalid: ({ errors }) => (
      errors.length > 0
    ),
    errors: (vm) => {
      if (!vm.rankSet) {
        return [];
      }

      const errors = [];
      if (vm.rankAlreadySet) {
        errors.push(`Rank ${vm.finalist.rank} is set on another finalist`);
      }
      if (!vm.rankInRange) {
        errors.push('Out of bounds, needs to be between 1 and 7');
      }
      if (errors.length === 0 && !vm.ranksSmallToLarge) {
        errors.push('No skipping, please enter ranks 1, 2, 3...');
      }
      return errors;
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
