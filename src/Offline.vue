<template lang="pug">
#offline
  h1 OFFLINE
  p Try again later.
</template>

<script lang="coffee">
</script>

<style lang="stylus">
@import './styles/_variables.styl'

#offline
  position fixed
  top 0
  bottom 0
  left 0
  right 0
  color $page-foreground-color
  background $page-background-color
  padding 1rem
  display flex
  flex-direction column
  justify-content center
  align-items center
</style>
