<template>
  <q-page class="flex flex-top">
    <WmsCrudTable api-base="core/asn/detail" :entity-title="t('menuLink.asnDetail')"
      :columns="cols" :form-fields="fields" :search-fields="['goods_name', 'asn_id']" />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import WmsCrudTable from 'components/wms/WmsCrudTable.vue'

const { t } = useI18n()

const cols = computed(() => [
  { name: 'asn_id', required: true, label: t('wms.sourceAsn'), align: 'left', field: 'asn_id' },
  { name: 'goods_name', label: t('wms.goodsName'), field: 'goods_name' },
  { name: 'goods_code', label: t('wms.goodsCode'), field: 'goods_code' },
  { name: 'qty', label: t('wms.detailQty'), field: 'qty' },
  { name: 'bin_code', label: t('wms.binCode'), field: 'bin_code' },
  { name: 'created_time', label: t('created_time'), field: 'created_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const fields = [
  { name: 'asn_id', label: 'ASN ID' },
  { name: 'goods_id', label: 'Goods ID' },
  { name: 'goods_name', label: 'Goods Name' },
  { name: 'goods_code', label: 'Goods Code' },
  { name: 'qty', label: 'Quantity' },
  { name: 'bin_id', label: 'Bin ID' },
  { name: 'bin_code', label: 'Bin Code' },
]
</script>
