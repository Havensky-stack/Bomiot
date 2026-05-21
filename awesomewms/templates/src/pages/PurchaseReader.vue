<template>
  <q-page class="flex flex-top">
    <WmsCrudTable api-base="core/purchase" :entity-title="t('menuLink.purchase')"
      :columns="cols" :form-fields="fields" :search-fields="['purchase_code', 'supplier_name']" />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import WmsCrudTable from 'components/wms/WmsCrudTable.vue'

const { t } = useI18n()

const cols = computed(() => [
  { name: 'purchase_code', required: true, label: t('wms.purchaseCode'), align: 'left', field: 'purchase_code' },
  { name: 'supplier_name', label: t('wms.supplierName'), field: 'supplier_name' },
  { name: 'goods_name', label: t('wms.goodsName'), field: 'goods_name' },
  { name: 'qty', label: t('wms.qty'), field: 'qty' },
  { name: 'status', label: t('wms.status'), field: 'status' },
  { name: 'created_time', label: t('created_time'), field: 'created_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const fields = [
  { name: 'purchase_code', label: 'Order Code' },
  { name: 'supplier_id', label: 'Supplier ID' },
  { name: 'supplier_name', label: 'Supplier Name' },
  { name: 'goods_id', label: 'Goods ID' },
  { name: 'goods_name', label: 'Goods Name' },
  { name: 'qty', label: 'Quantity' },
  { name: 'status', label: 'Status' },
]
</script>
