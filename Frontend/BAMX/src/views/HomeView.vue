<script setup>
import Donor from '../components/Donor.vue'
</script>

<template>
  <main>
    <div class="container">
      <h1>Donadores</h1>
      <table style="width:100%">
        <thead>
          <tr>
            <th>Id</th>
            <th>Nombre</th>
            <th>Ciudad</th>
            <th>Organizaci&oacute;n/Gremio</th>
            <th>Tipo de aliado</th>
            <th>Correo electr&oacute;nico</th>
          </tr>
        </thead>
        <tbody>
          <Donor />
        </tbody>
      </table>
    </div>
  </main>
</template>

<style>
h1{
  text-align: center;
  padding: 10px 0;
  font-style: italic;
}
</style>