// Copyright 2020 Matthew B. Gray
// Copyright 2021 Fred Bauer
//
// Licensed under the Apache License, Version 2.0 (the "License");
// 10-may-21 FNB added check for valid vote, because valid is not a reliable indicator.

<template>
  <div v-if="0 < category.finalists.length" class="category-component l-v-spacing">
    <h2>{{ category.name }}</h2>
    <ul class="list-group list-group-flush text-dark l-v-spacing">
      <finalist
        v-for="finalist in category.finalists"
        :key="finalist.id"
        :finalist="finalist"
        :ranks="ranks"
        @valid="valid = $event"
      />
    </ul>

    <button
      v-if="test(ranks)"
      v-on:click="save(category)"
      v-bind:key="category.id"
      class="btn"
    >Vote for {{ category.name }}</button>
  </div>
</template>

<script>
import Finalist from './finalist.vue';

export default {
  props: ['category'],
  data: () => (
    {
      valid: true,
    }
  ),
  computed: {
    ranks: ({ category }) => {
      const ranks = category.finalists.map((finalist) => finalist.rank);
      return ranks
        .filter((r) => !!r)
        .map((r) => parseInt(r, 10))
        .sort();
    },
  },
  components: { Finalist },
  methods: {
    save: (category) => {
      fetch('', {
        body: JSON.stringify({ category }),
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
      });
    },
    test: (list) => {
      for (let index = 0; index < list.length; index++) {
      if (index + 1 != list[index]) {return false}
      }
      return true;
    },
  },
};
</script>

<style scoped>
</style>
