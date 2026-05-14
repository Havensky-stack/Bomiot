<template>
  <q-page class="flex flex-center">
    <!-- 使用 GIF 图片替换 Lottie 动画 -->
    <img 
      src="/welcome-animation.gif" 
      alt="Welcome" 
      style="max-width: 60%; height: auto;"
    />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useMeta } from "quasar"
import { useI18n } from "vue-i18n"

const { t } = useI18n()

const title = computed(()=> { return t('title') })
const description = computed(()=> { return t('description') })
const keywords = computed(()=> { return t('keywords') })

useMeta(() => {
  return {
    title: title.value,
    meta: {
        description: { name: 'description', content: description.value },
        keywords: { name: 'keywords', content: keywords.value },
      }
    }
  })
</script>