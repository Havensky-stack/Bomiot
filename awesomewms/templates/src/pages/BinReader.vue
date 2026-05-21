<template>
  <q-page class="flex flex-top">
    <WmsCrudTable api-base="core/bin" :entity-title="t('menuLink.bin')"
      :columns="cols" :form-fields="fields" :search-fields="['bin_code', 'bin_name']" />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import WmsCrudTable from 'components/wms/WmsCrudTable.vue'

const { t } = useI18n()

const cols = computed(() => [
  { name: 'bin_code', required: true, label: t('wms.binCode'), align: 'left', field: 'bin_code' },
  { name: 'bin_name', label: t('wms.binName'), field: 'bin_name' },
  { name: 'bin_type', label: t('wms.binType'), field: 'bin_type' },
  { name: 'bin_capacity', label: t('wms.binCapacity'), field: 'bin_capacity' },
  { name: 'created_time', label: t('created_time'), field: 'created_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const fields = [
  { name: 'bin_code', label: 'Bin Code' },
  { name: 'bin_name', label: 'Bin Name' },
  { name: 'bin_type', label: 'Bin Type' },
  { name: 'bin_capacity', label: 'Capacity' },
]
</script>
