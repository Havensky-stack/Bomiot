<template>
  <q-page class="flex flex-top">
    <div class="q-pa-md" style="width: 100%">
      <q-table :class="$q.dark.isActive ? 'my-sticky-header-last-column-table-dark' : 'my-sticky-header-last-column-table'"
        flat bordered :rows="rows" :columns="cols" row-key="index" v-model:pagination="pagination" separator="cell"
        :no-data-label="t('nodata')" :rows-per-page-label="t('per_page')"
        :rows-per-page-options="[10, 30, 50, 200, 1000]"
        :table-style="{ height: screenHeight, width: screenWidth }"
        :card-style="{ backgroundColor: cardBackground }" @request="onRequest">
        <template v-slot:top="props">
          <q-btn-group flat>
            <q-btn :label="t('refresh')" icon="refresh" @click="onRequest()" />
            <q-btn :label="t('new')" icon="add" @click="createData()" />
          </q-btn-group>
          <q-space />
          <q-input dense debounce="300" color="primary" v-model="search" @input="onRequest()" @keyup.enter="onRequest()">
            <template v-slot:append><q-icon name="search" /></template>
          </q-input>
          <q-btn flat round dense :icon="props.inFullscreen ? 'fullscreen_exit' : 'fullscreen'"
            @click="props.toggleFullscreen" />
        </template>
        <template v-slot:body-cell="props">
          <q-td :props="props">
            <div v-if="props.col.name === 'status'">
              <q-badge :color="statusColor(props.value)">{{ props.value || t('wms.pending') }}</q-badge>
            </div>
            <div v-else-if="props.col.name === 'action'">
              <q-btn round flat icon="edit" @click="editData(props.rowIndex)" />
              <q-btn round flat color="green" icon="check_circle" @click="confirmASN(props.rowIndex)"
                v-if="props.row.status !== 'confirmed' && props.row.status !== 'received'" />
              <q-btn round flat icon="delete_sweep" @click="deleteData(props.rowIndex)" />
            </div>
            <div v-else>{{ props.value }}</div>
          </q-td>
        </template>
        <template v-slot:pagination>
          {{ t('total') }}{{ pagesNumber }} {{ t('page') }}
          <q-pagination v-model="pagination.page" :max="pagesNumber" input input-class="text-orange-10"
            @update:model-value="onRequest()" />
        </template>
      </q-table>
    </div>

    <q-dialog v-model="formData">
      <q-card style="width: 500px; max-width: 90vw" class="q-px-sm q-pb-md">
        <q-card-section><div class="text-h6">{{ mode === 'create' ? t('new') : t('edit') }} - ASN</div></q-card-section>
        <q-card-section class="q-pt-none">
          <q-input dense v-model="form.asn_code" :label="t('wms.asnCode')" />
          <q-input dense v-model="form.asn_type" :label="t('wms.asnType')" />
          <q-input dense v-model="form.supplier_name" :label="t('wms.supplierName')" />
          <q-input dense v-model="form.expected_time" :label="t('wms.expectedTime')" type="date" />
        </q-card-section>
        <q-card-actions align="right">
          <q-btn flat :label="t('cancel')" color="primary" v-close-popup @click="cancelSubmit()" />
          <q-btn flat :label="t('submit')" color="primary" v-close-popup @click="submitData()" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useQuasar } from 'quasar'
import { useI18n } from 'vue-i18n'
import { get, post } from 'boot/axios'
import { useTokenStore } from 'stores/token'
import { useLanguageStore } from 'stores/language'
import emitter from 'boot/bus.js'

const { t } = useI18n()
const $q = useQuasar()
const tokenStore = useTokenStore()
const langStore = useLanguageStore()

const cols = computed(() => [
  { name: 'asn_code', required: true, label: t('wms.asnCode'), align: 'left', field: 'asn_code' },
  { name: 'asn_type', label: t('wms.asnType'), field: 'asn_type' },
  { name: 'supplier_name', label: t('wms.supplierName'), field: 'supplier_name' },
  { name: 'status', label: t('wms.status'), field: 'status' },
  { name: 'expected_time', label: t('wms.expectedTime'), field: 'expected_time' },
  { name: 'created_time', label: t('created_time'), field: 'created_time' },
  { name: 'action', label: t('action'), align: 'right' },
])

const rows = ref([])
const search = ref('')
const formData = ref(false)
const form = ref({})
const mode = ref('create')
const rowsCount = ref(0)
const token = computed(() => tokenStore.token)

const pagination = ref({ sortBy: 'updated_time', descending: false, page: 1, rowsPerPage: 30, rowsNumber: 30 })

const pagesNumber = computed(() => token.value ? Math.ceil(rowsCount.value / pagination.value.rowsPerPage) : 0)
const screenHeight = ref(`${$q.screen.height * 0.73}px`)
const screenWidth = ref(`${$q.screen.width * 0.825}px`)
const cardBackground = ref($q.dark.isActive ? '#121212' : '#ffffff')

function statusColor(s) { return s === 'confirmed' || s === 'received' ? 'green' : 'orange' }

function onRequest(p) {
  let rd = p || { pagination: pagination.value }
  const params = search.value ? JSON.stringify({ data__asn_code__icontains: search.value }) : '{}'
  get({ url: 'core/asn/', params: { params, page: rd.pagination.page, max_page: rd.pagination.rowsPerPage } })
    .then(res => {
      rows.value = (res.results || []).map(r => ({ ...r, ...(r.data || {}) }))
      rowsCount.value = res.count
    }).catch(err => { $q.notify({ type: 'error', message: err?.detail || 'Error' }); $q.loading.hide() })
  pagination.value = rd.pagination
}

function createData() { mode.value = 'create'; form.value = {}; formData.value = true }
function editData(e) { mode.value = 'update'; form.value = { ...rows.value[e] }; formData.value = true }

function deleteData(e) {
  $q.dialog({ dark: $q.dark.isActive, title: t('delete'), message: t('confirmnotice'), cancel: true })
    .onOk(() => post('core/asn/delete/', { id: rows.value[e].id }).then(() => onRequest())
      .catch(err => { $q.notify({ type: 'error', message: err?.detail || 'Error' }); $q.loading.hide() }))
}

function confirmASN(e) {
  $q.dialog({ dark: $q.dark.isActive, title: t('wms.confirmASN'), message: t('confirmnotice'), cancel: true })
    .onOk(() => post('wmsapp/asn/confirm/', { id: rows.value[e].id }).then(() => onRequest())
      .catch(err => { $q.notify({ type: 'error', message: err?.detail || 'Error' }); $q.loading.hide() }))
}

function cancelSubmit() { formData.value = false; form.value = {} }

async function submitData() {
  const payload = mode.value === 'create' ? { data: form.value } : { id: form.value.id, data: form.value }
  const url = mode.value === 'create' ? 'core/asn/create/' : 'core/asn/update/'
  await post(url, payload).then(() => { onRequest(); cancelSubmit() })
    .catch(err => { $q.notify({ type: 'error', message: err?.detail || 'Error' }); $q.loading.hide() })
}

onMounted(() => { emitter.on('needLogin', (p) => { if (p) { rows.value = []; search.value = ''; rowsCount.value = 0 } }); onRequest() })
watch(() => $q.dark.isActive, v => { cardBackground.value = v ? '#121212' : '#ffffff' })
watch(() => langStore.langData, () => { onRequest() })
</script>
