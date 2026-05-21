<template>
  <q-page class="flex flex-top">
    <WmsCrudTable api-base="core/customer" :entity-title="t('menuLink.customer')"
      :columns="cols" :form-fields="fields" :search-fields="['customer_name', 'customer_phone']" />
  </q-page>
</template>

<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import WmsCrudTable from 'components/wms/WmsCrudTable.vue'

const { t } = useI18n()

const cols = computed(() => [
  { name: 'customer_name', required: true, label: t('wms.customerName'), align: 'left', field: 'customer_name' },
  { name: 'customer_contact', label: t('wms.customerContact'), field: 'customer_contact' },
  { name: 'customer_phone', label: t('wms.customerPhone'), field: 'customer_phone' },
  { name: 'customer_address', label: t('wms.customerAddress'), field: 'customer_address' },
  { name: 'created_time', label: t('created_time'), field: 'created_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const fields = [
  { name: 'customer_name', label: 'Customer Name' },
  { name: 'customer_contact', label: 'Contact' },
  { name: 'customer_phone', label: 'Phone' },
  { name: 'customer_address', label: 'Address' },
]
</script>
