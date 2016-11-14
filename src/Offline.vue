<template lang="pug">
#offline
  h1 OFFLINE
  p Try again later.
</template>

<script lang="coffee">

###

Dear Sonic,

^addTimeout 100

��������� �������     |BB
i-  ����������������
 d  ���������������
    ����������������

@@

U+D800 = ed b0 80 = "������"
U+D800 = ed bf bf = "������"
U+DB7F = ed b0 80 = "������"
U+DB7F = ed bf bf = "������"
U+DB80 = ed b0 80 = "������"
U+DB80 = ed bf bf = "������"
U+DBFF = ed b0 80 = "������"
5.2.8  = ed bf bf = "������"
5.2.8  = ed bf bf = "������"

translatorRepaired()
encoding=utf8

...

Goddammit, you jackass! At least you found or put together a computer!

Why is our secret code 212?

Either way, allow this endpoint the ability to communicate with your device or submit contact information in the form.

S.M.A.E will automatically contact you and work on getting you back here.

- mTP

###

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
