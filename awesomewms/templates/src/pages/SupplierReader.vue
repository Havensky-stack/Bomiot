<template>
  <q-page class="flex flex-top">
    <WmsCrudTable api-base="core/supplier" :entity-title="t('menuLink.supplier')"
      :columns="cols" :form-fields="fields" :search-fields="['supplier_name', 'supplier_phone']" />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import WmsCrudTable from 'components/wms/WmsCrudTable.vue'

const { t } = useI18n()

const cols = computed(() => [
  { name: 'supplier_name', required: true, label: t('wms.supplierName'), align: 'left', field: 'supplier_name' },
  { name: 'supplier_contact', label: t('wms.supplierContact'), field: 'supplier_contact' },
  { name: 'supplier_phone', label: t('wms.supplierPhone'), field: 'supplier_phone' },
  { name: 'supplier_address', label: t('wms.supplierAddress'), field: 'supplier_address' },
  { name: 'created_time', label: t('created_time'), field: 'created_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const fields = [
  { name: 'supplier_name', label: 'Supplier Name' },
  { name: 'supplier_contact', label: 'Contact' },
  { name: 'supplier_phone', label: 'Phone' },
  { name: 'supplier_address', label: 'Address' },
]
</script>
