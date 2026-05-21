<template>
  <q-page class="flex flex-top">
    <WmsCrudTable api-base="core/stock" :entity-title="t('menuLink.stock')"
      :columns="cols" :form-fields="fields" :search-fields="['goods_name', 'bin_code', 'batch_no']" />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import WmsCrudTable from 'components/wms/WmsCrudTable.vue'

const { t } = useI18n()

const cols = computed(() => [
  { name: 'goods_name', required: true, label: t('wms.goodsName'), align: 'left', field: 'goods_name' },
  { name: 'bin_code', label: t('wms.binCode'), field: 'bin_code' },
  { name: 'qty', label: t('wms.qty'), field: 'qty' },
  { name: 'batch_no', label: t('wms.batchNo'), field: 'batch_no' },
  { name: 'goods_id', label: t('wms.goodsId'), field: 'goods_id' },
  { name: 'bin_id', label: t('wms.binId'), field: 'bin_id' },
  { name: 'updated_time', label: t('updated_time'), field: 'updated_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const fields = [
  { name: 'goods_id', label: 'Goods ID' },
  { name: 'goods_name', label: 'Goods Name' },
  { name: 'bin_id', label: 'Bin ID' },
  { name: 'bin_code', label: 'Bin Code' },
  { name: 'qty', label: 'Quantity' },
  { name: 'batch_no', label: 'Batch No.' },
]
</script>
