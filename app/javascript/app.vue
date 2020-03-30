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
  <div class="app-component">
    <category
      v-for="category in categories"
      v-bind:category="category"
    />
  </div>
</template>

<script>
import Finalist from './finalist.vue'
import Category from './category.vue'

export default {
  components: { Category },
  data: () => (
    {
      categories: [
        {
          name: "Best Novel",
          finalists: [
            {
              name: "The Calculating Stars, by Mary Robinette Kowal (Tor)",
              rank: 1,
            },
            {
              name: "Record of a Spaceborn Few, by Becky Chambers (Hodder & Stoughton / Harper Voyager)",
              rank: null,
            },
            {
              name: "Revenant Gun, by Yoon Ha Lee (Solaris)",
              rank: null,
            },
            {
              name: "Space Opera, by Catherynne M. Valente (Saga)",
              rank: null,
            },
            {
              name: "Spinning Silver, by Naomi Novik (Del Rey / Macmillan)",
              rank: null,
            },
            {
              name: "Trail of Lightning, by Rebecca Roanhorse (Saga)",
              rank: null,
            },
            {
              name: "No Award",
              rank: null,
            },
          ]
        },
        {
          name: "Best Novela",
          finalists: [
            {
              name: "Artificial Condition, by Martha Wells (Tor.com Publishing)",
              rank: null,
            },
            {
              name: "Beneath the Sugar Sky, by Seanan McGuire (Tor.com Publishing)",
              rank: null,
            },
            {
              name: "Binti: The Night Masquerade, by Nnedi Okorafor (Tor.com Publishing)",
              rank: null,
            },
            {
              name: "The Black God’s Drums, by P. Djèlí Clark (Tor.com Publishing)",
              rank: null,
            },
            {
              name: "Gods, Monsters, and the Lucky Peach, by Kelly Robson (Tor.com Publishing)",
              rank: null,
            },
            {
              name: "The Tea Master and the Detective, by Aliette de Bodard (Subterranean Press / JABberwocky Literary Agency)",
              rank: null,
            },
            {
              name: "No Award",
              rank: null,
            },
          ]
        }
      ]
    }
  ),
  computed: {},
}
</script>

<style scoped>
input {
  width: 25px;
  margin: 0 5px 5px 0;
  text-align: center;
  line-height: 1em;
}
</style>
