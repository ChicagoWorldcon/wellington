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

// This app is just for Hugo Finalists. This can and should be moved if
// we need to add more vue things.
<template>
  <div class="app-component">
    <category
      v-for="category in categories"
      :category="category"
      :key="category.id"
    />
  </div>
</template>

<script>
import Category from './category.vue';

export default {
  components: { Category },
  props: ['categories'],
};
</script>

<style scoped>
input {
  width: 25px;
  margin: 0 5px 5px 0;
  text-align: center;
  line-height: 1em;
}
</style>
