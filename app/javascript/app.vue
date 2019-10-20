<template>
  <div id="app">
    <table class="table table-hover table-striped table-dark table-responsive-lg">
      <thead>
        <th>{{ message }}</th>
      </thead>

      <tbody>
        <tr>
          <td>{{ message }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  data: () => (
    { message: 'Hello Vue!' }
  ),
};
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
