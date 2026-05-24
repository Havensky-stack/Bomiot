<template>
  <q-page class="flex flex-center">
    <div class="text-center q-pa-md">
      <div class="text-h3 text-primary q-mb-md">{{ t('title') }}</div>
      <div class="text-h5 text-grey q-mb-lg">{{ t('description') }}</div>
      <q-btn color="primary" size="lg" :label="t('wms.wmsDashboard')" icon="dashboard" @click="$router.push('/wms-dashboard')" />
    </div>
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useMeta } from "quasar"
import { useI18n } from "vue-i18n"

const { t } = useI18n()

const title = computed(()=> t('title'))
const description = computed(()=> t('description'))
const keywords = computed(()=> t('keywords'))

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
