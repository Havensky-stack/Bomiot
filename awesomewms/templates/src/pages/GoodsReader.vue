<template>
  <q-page class="flex flex-top">
    <WmsCrudTable api-base="core/goods" :entity-title="t('menuLink.goods')"
      :columns="goodsCols" :form-fields="goodsFields" :search-fields="['goods_name', 'goods_code']" />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import WmsCrudTable from 'components/wms/WmsCrudTable.vue'

const { t } = useI18n()

const goodsCols = computed(() => [
  { name: 'goods_name', required: true, label: t('wms.goodsName'), align: 'left', field: 'goods_name' },
  { name: 'goods_code', label: t('wms.goodsCode'), field: 'goods_code' },
  { name: 'goods_spec', label: t('wms.goodsSpec'), field: 'goods_spec' },
  { name: 'goods_unit', label: t('wms.goodsUnit'), field: 'goods_unit' },
  { name: 'goods_price', label: t('wms.goodsPrice'), field: 'goods_price' },
  { name: 'created_time', label: t('created_time'), field: 'created_time' },
  { name: 'updated_time', label: t('updated_time'), field: 'updated_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const goodsFields = [
  { name: 'goods_name', label: 'Goods Name' },
  { name: 'goods_code', label: 'Goods Code' },
  { name: 'goods_spec', label: 'Specification' },
  { name: 'goods_unit', label: 'Unit' },
  { name: 'goods_price', label: 'Price' },
  { name: 'goods_desc', label: 'Description' },
]
</script>
