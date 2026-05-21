<template>
  <q-page class="q-pa-md">
    <div class="text-h5 q-mb-md">{{ t('wms.wmsDashboard') }}</div>

    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-4 col-md-2" v-for="card in kpiCards" :key="card.label">
        <q-card flat bordered :class="$q.dark.isActive ? 'bg-grey-10' : 'bg-white'">
          <q-card-section class="text-center">
            <div class="text-caption text-grey">{{ card.label }}</div>
            <div class="text-h4 text-primary">{{ card.value }}</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-12 col-md-6">
        <q-card flat bordered :class="$q.dark.isActive ? 'bg-grey-10' : 'bg-white'">
          <q-card-section>
            <div class="text-h6">{{ t('wms.asnToday') }} / {{ t('wms.dnToday') }}</div>
          </q-card-section>
          <q-card-section>
            <StackedBar v-if="chartReady" :chart-data="asnDnData" :title="'Inbound / Outbound'"
              style="width: 100%; height: 300px" />
          </q-card-section>
        </q-card>
      </div>
      <div class="col-12 col-md-6">
        <q-card flat bordered :class="$q.dark.isActive ? 'bg-grey-10' : 'bg-white'">
          <q-card-section>
            <div class="text-h6">{{ t('wms.lowStock') }}</div>
          </q-card-section>
          <q-card-section>
            <q-list separator>
              <q-item v-for="item in dashboard.low_stock" :key="item.id">
                <q-item-section>
                  <q-item-label>{{ item.goods_name }} @ {{ item.bin_code }}</q-item-label>
                  <q-item-label caption>Qty: {{ item.qty }}</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-badge color="red">{{ item.qty }}</q-badge>
                </q-item-section>
              </q-item>
              <q-item v-if="!dashboard.low_stock || dashboard.low_stock.length === 0">
                <q-item-section><q-item-label class="text-grey">{{ t('nodata') }}</q-item-label></q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { useQuasar } from 'quasar'
import { get } from 'boot/axios'
import { useTokenStore } from 'stores/token'
import { useLanguageStore } from 'stores/language'
import StackedBar from 'components/echarts/StackedBar.vue'

const { t } = useI18n()
const $q = useQuasar()
const tokenStore = useTokenStore()
const langStore = useLanguageStore()
const token = computed(() => tokenStore.token)

const dashboard = ref({})
const chartReady = ref(false)

const kpiCards = computed(() => [
  { label: t('wms.totalGoods'), value: dashboard.value.total_goods || 0 },
  { label: t('wms.totalBin'), value: dashboard.value.total_bin || 0 },
  { label: t('wms.totalStock'), value: dashboard.value.total_stock || 0 },
  { label: t('wms.totalSupplier'), value: dashboard.value.total_supplier || 0 },
  { label: t('wms.totalCustomer'), value: dashboard.value.total_customer || 0 },
])

const asnDnData = computed(() => ({
  categories: ['Today', 'This Week'],
  series: [
    { name: t('wms.asnToday'), data: [dashboard.value.asn_today || 0, dashboard.value.asn_week || 0] },
    { name: t('wms.dnToday'), data: [dashboard.value.dn_today || 0, dashboard.value.dn_week || 0] },
  ]
}))

function loadDashboard() {
  get({ url: 'wmsapp/dashboard/' }).then(res => {
    dashboard.value = res
    chartReady.value = true
  }).catch(err => {
    console.error('Dashboard load error:', err)
    $q.loading.hide()
  })
}

onMounted(() => { loadDashboard() })
watch(() => token.value, () => { if (token.value) loadDashboard() })
watch(() => langStore.langData, () => { loadDashboard() })
</script>
