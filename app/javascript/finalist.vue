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
  <li class="list-group-item">
    <input
      type="text"
      v-model="finalist.rank"
      v-bind:class="inputClasses"
    >
    <span v-bind:class="textClasses">
      {{ finalist.name }}
    </span>
  </li>
</template>

<script>
export default {
  props: ["finalist", "ranks"],
  computed: {
    isValid: () => {
      return false;
    },
    textClasses: () => (
      {
        "text-danger": true
      }
    ),
    inputClasses: () => (
      {
        "is-invalid": true,
        "form-control": true,
        "text-danger": true,
      }
    ),
  }
}
</script>

<style>
input {
  width: 25px;
  margin: 0 5px 5px 0;
  text-align: center;
  line-height: 1em;
}

.is-invalid {
  width: 75px;
  color: #f00;
}
</style>
