// Copyright 2020 Matthew B. Gray
// Copyright 2021 Fred Bauer
//
// Licensed under the Apache License, Version 2.0 (the "License");
// 28-APR-21 FNB allow finalist names to contain HTML for nice formatting
// 25-MAY-21 FNB Accessability updates
// 22-aug-21 FNB Allow only 1-7 to be input for rank

// NOTE: Changes to VUE require rails server restart!

<template>
  <li class="finalist-component list-group-item">
    <div>
      <input
        type="text"
        title="ranking"
        v-model.number="finalist.rank"
        :class="{ 'text-danger': invalid }"
        @change='changeRank()'
        @keyup='changeRank()'
        @input='check0'
      >
      <span v-bind:class="{ 'text-danger': invalid }" v-html="finalist.name">
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
    rankSet: (vm) => vm.finalist.rank > 0,
    rankInRange: ({ finalist }) => (
      finalist.rank === null || finalist.rank === '' || (finalist.rank >= 1 && finalist.rank <= 7)
    ),
    rankAlreadySet: ({ finalist, ranks }) => {
      if (finalist.rank != null) {
        const matching = ranks.filter((rank) => rank === finalist.rank);
        return matching.length > 1;
      }
      return false;
    },
    ranksSmallToLarge: ({ finalist, ranks }) => {
      if (finalist.rank === null || finalist.rank === '') {
        return true;
      }
      const expectedOffset = finalist.rank - 1;
      return ranks[expectedOffset] === finalist.rank;
    },
    // TODO check out validation options in vue's model
    // https://vuejs.org/v2/api/#model
    invalid: ({ errors }) => (
      errors.length > 0
    ),
    errors: (vm) => {
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
  methods: {
    changeRank() {
      this.$emit('valid', this.errors.length === 0);
    },
    check0(event) {
      const value = event.target.value
      if (String(value) === '0') { this.finalist.rank = '' }
      const validInput = new RegExp("[^1-7]",)
      if (validInput.test(String(value))) { this.finalist.rank = '' }
      this.$forceUpdate()
    },
  },
};
</script>

<style>
input {
  width: 40px;
  margin: 0 5px 5px 0;
  text-align: center;
  line-height: 1em;
}
</style>
