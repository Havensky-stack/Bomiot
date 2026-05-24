<template>
  <q-page class="q-pa-md">
    <div class="welcome-banner q-mb-lg">
      <div class="text-h4 text-primary text-weight-bold">{{ t('title') }}</div>
      <div class="text-subtitle1 text-grey-7">{{ t('description') }}</div>
    </div>

    <div class="text-h6 text-weight-medium q-mb-sm">{{ t('home.systemOverview') }}</div>
    <div class="row q-col-gutter-md q-mb-md">
      <div class="col-6 col-sm-4 col-md-2" v-for="card in kpiCards" :key="card.label">
        <q-card flat bordered :class="[$q.dark.isActive ? 'bg-grey-10' : 'bg-white', 'kpi-card']">
          <q-card-section class="text-center">
            <q-icon :name="card.icon" size="28px" :color="card.color" class="q-mb-xs" />
            <div class="text-h5 text-weight-bold" :class="card.colorClass">{{ card.value }}</div>
            <div class="text-caption text-grey-7">{{ card.label }}</div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <div v-if="dashboard.low_stock && dashboard.low_stock.length > 0" class="q-mb-md">
      <q-banner rounded class="bg-warning text-black">
        <template v-slot:avatar>
          <q-icon name="warning" color="black" size="24px" />
        </template>
        <span class="text-body2 text-weight-medium">
          {{ dashboard.low_stock.length }} {{ t('home.lowStockWarning') }}
        </span>
        <template v-slot:action>
          <q-btn flat dense :label="t('wms.lowStock')" @click="$router.push('/wms-dashboard')" />
        </template>
      </q-banner>
    </div>

    <div class="text-h6 text-weight-medium q-mb-sm">{{ t('home.quickActions') }}</div>
    <div class="row q-col-gutter-md q-mb-lg">
      <div class="col-6 col-sm-4 col-md-3" v-for="action in quickActions" :key="action.link">
        <q-card flat bordered :class="[$q.dark.isActive ? 'bg-grey-10' : 'bg-white', 'action-card']"
          clickable v-ripple @click="$router.push(action.link)">
          <q-card-section class="flex items-center">
            <q-icon :name="action.icon" size="32px" :color="action.color" class="q-mr-md" />
            <div>
              <div class="text-body1 text-weight-medium">{{ action.label }}</div>
              <div class="text-caption text-grey-7">{{ action.desc }}</div>
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>

    <div class="row q-col-gutter-md">
      <div class="col-12 col-md-6">
        <q-card flat bordered :class="[$q.dark.isActive ? 'bg-grey-10' : 'bg-white']">
          <q-card-section>
            <div class="text-h6 text-weight-medium">{{ t('home.recentActivity') }}</div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <q-list separator>
              <q-item v-for="item in recent" :key="item.type + '-' + item.id" clickable
                @click="$router.push('/' + item.type)">
                <q-item-section avatar>
                  <q-icon :name="item.type === 'asn' ? 'download' : 'upload'"
                    :color="item.type === 'asn' ? 'green' : 'orange'" size="24px" />
                </q-item-section>
                <q-item-section>
                  <q-item-label>{{ item.code || '#' + item.id }}</q-item-label>
                  <q-item-label caption>{{ item.type_label }} &middot; {{ item.time }}</q-item-label>
                </q-item-section>
                <q-item-section side>
                  <q-badge :color="item.status === 'confirmed' ? 'green' : 'grey'" outline>
                    {{ item.status }}
                  </q-badge>
                </q-item-section>
              </q-item>
              <q-item v-if="recent.length === 0">
                <q-item-section>
                  <q-item-label class="text-grey">{{ t('home.noRecent') }}</q-item-label>
                </q-item-section>
              </q-item>
            </q-list>
          </q-card-section>
        </q-card>
      </div>
      <div class="col-12 col-md-6">
        <q-card flat bordered :class="[$q.dark.isActive ? 'bg-grey-10' : 'bg-white']">
          <q-card-section>
            <div class="text-h6 text-weight-medium">{{ t('wms.wmsDashboard') }}</div>
          </q-card-section>
          <q-card-section class="q-pt-none">
            <div class="row q-col-gutter-sm q-mb-md">
              <div class="col-6">
                <q-card flat bordered class="bg-green-1">
                  <q-card-section class="text-center">
                    <div class="text-caption text-grey-8">{{ t('wms.asnToday') }}</div>
                    <div class="text-h4 text-green text-weight-bold">{{ dashboard.asn_today || 0 }}</div>
                  </q-card-section>
                </q-card>
              </div>
              <div class="col-6">
                <q-card flat bordered class="bg-orange-1">
                  <q-card-section class="text-center">
                    <div class="text-caption text-grey-8">{{ t('wms.dnToday') }}</div>
                    <div class="text-h4 text-orange text-weight-bold">{{ dashboard.dn_today || 0 }}</div>
                  </q-card-section>
                </q-card>
              </div>
            </div>
            <div class="text-center">
              <q-btn color="primary" size="md" :label="t('home.goDashboard')" icon-right="arrow_forward"
                @click="$router.push('/wms-dashboard')" />
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useMeta, useQuasar } from 'quasar'
import { useI18n } from 'vue-i18n'
import { get } from 'boot/axios'
import { useTokenStore } from 'stores/token'
import { useLanguageStore } from 'stores/language'

const { t } = useI18n()
const $q = useQuasar()
const tokenStore = useTokenStore()
const langStore = useLanguageStore()
const token = computed(() => tokenStore.token)

const dashboard = ref({})
const recent = ref([])

const kpiCards = computed(() => [
  { label: t('wms.totalGoods'), value: dashboard.value.total_goods || 0, icon: 'inventory_2', color: 'primary', colorClass: 'text-primary' },
  { label: t('wms.totalBin'), value: dashboard.value.total_bin || 0, icon: 'grid_view', color: 'teal', colorClass: 'text-teal' },
  { label: t('wms.totalStock'), value: dashboard.value.total_stock || 0, icon: 'store', color: 'deep-orange', colorClass: 'text-deep-orange' },
  { label: t('wms.totalSupplier'), value: dashboard.value.total_supplier || 0, icon: 'local_shipping', color: 'purple', colorClass: 'text-purple' },
  { label: t('wms.totalCustomer'), value: dashboard.value.total_customer || 0, icon: 'people', color: 'brown', colorClass: 'text-brown' },
  { label: t('wms.asnWeek'), value: dashboard.value.asn_week || 0, icon: 'download', color: 'green', colorClass: 'text-green' },
])

const quickActions = [
  { label: t('menuLink.goods'), desc: t('wms.goodsName'), icon: 'inventory_2', color: 'primary', link: '/goods' },
  { label: t('menuLink.bin'), desc: t('wms.binName'), icon: 'grid_view', color: 'teal', link: '/bin' },
  { label: t('menuLink.asn'), desc: t('wms.asnCode'), icon: 'download', color: 'green', link: '/asn' },
  { label: t('menuLink.dn'), desc: t('wms.dnCode'), icon: 'upload', color: 'orange', link: '/dn' },
  { label: t('menuLink.stock'), desc: t('wms.qty'), icon: 'warehouse', color: 'deep-orange', link: '/stock' },
  { label: t('menuLink.supplier'), desc: t('wms.supplierName'), icon: 'local_shipping', color: 'purple', link: '/supplier' },
  { label: t('menuLink.customer'), desc: t('wms.customerName'), icon: 'people', color: 'brown', link: '/customer' },
  { label: t('menuLink.purchase'), desc: t('wms.purchaseCode'), icon: 'receipt_long', color: 'blue-grey', link: '/purchase' },
]

function loadDashboard() {
  get({ url: 'wmsapp/dashboard/' }).then(res => {
    dashboard.value = res
  }).catch(err => {
    console.error('Dashboard load error:', err)
  })
}

function loadRecent() {
  get({ url: 'wmsapp/recent/', params: { limit: '5' } }).then(res => {
    recent.value = res.recent || []
  }).catch(err => {
    console.error('Recent load error:', err)
  })
}

const title = computed(() => t('title'))
const description = computed(() => t('description'))
const keywords = computed(() => t('keywords'))

useMeta(() => {
  return {
    title: title.value,
    meta: {
      description: { name: 'description', content: description.value },
      keywords: { name: 'keywords', content: keywords.value },
    }
  }
})

onMounted(() => {
  loadDashboard()
  loadRecent()
})

watch(() => token.value, () => {
  if (token.value) {
    loadDashboard()
    loadRecent()
  }
})

watch(() => langStore.langData, () => {
  loadDashboard()
  loadRecent()
})
</script>

<style scoped>
.kpi-card {
  transition: transform 0.2s ease;
}
.kpi-card:hover {
  transform: translateY(-3px);
}
.action-card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.action-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
</style>
