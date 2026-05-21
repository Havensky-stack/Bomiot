<template>
  <div class="q-pa-md">
    <q-table
      :class="$q.dark.isActive ? 'my-sticky-header-last-column-table-dark' : 'my-sticky-header-last-column-table'"
      flat
      bordered
      :rows="rows"
      :columns="columns"
      row-key="index"
      v-model:pagination="pagination"
      separator="cell"
      :no-data-label="t('nodata')"
      :rows-per-page-label="t('per_page')"
      :rows-per-page-options="[10, 30, 50, 200, 1000]"
      :table-style="{ height: screenHeight, width: screenWidth }"
      :card-style="{ backgroundColor: cardBackground }"
      @request="onRequest"
    >
      <template v-slot:top="props">
        <q-btn-group flat>
          <q-btn :label="t('refresh')" icon="refresh" @click="onRequest()">
            <q-tooltip class="bg-indigo" :offset="[10, 10]" content-style="font-size: 12px">{{ t('refreshdata') }}</q-tooltip>
          </q-btn>
          <q-btn :label="t('new')" icon="add" @click="createData()">
            <q-tooltip class="bg-indigo" :offset="[10, 10]" content-style="font-size: 12px">{{ t('new') }}</q-tooltip>
          </q-btn>
        </q-btn-group>
        <q-space />
        <q-input dense debounce="300" color="primary" v-model="search" @input="onRequest()" @keyup.enter="onRequest()">
          <template v-slot:append>
            <q-icon name="search" />
          </template>
        </q-input>
        <q-btn flat round dense :icon="props.inFullscreen ? 'fullscreen_exit' : 'fullscreen'"
          @click="props.toggleFullscreen" />
      </template>

      <template v-slot:body-cell="props">
        <q-td :props="props">
          <div v-if="props.col.name === 'action'">
            <q-btn round flat icon="edit" @click="editData(props.rowIndex)">
              <q-tooltip class="bg-indigo" :offset="[10, 10]" content-style="font-size: 12px">{{ t('edit') }}</q-tooltip>
            </q-btn>
            <q-btn round flat icon="delete_sweep" @click="deleteData(props.rowIndex)">
              <q-tooltip class="bg-indigo" :offset="[10, 10]" content-style="font-size: 12px">{{ t('delete') }}</q-tooltip>
            </q-btn>
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
      <q-card-section>
        <div class="text-h6">{{ mode === 'create' ? t('new') : t('edit') }} - {{ entityTitle }}</div>
      </q-card-section>
      <q-card-section class="q-pt-none">
        <q-input v-for="field in formFields" :key="field.name" dense :label="field.label"
          v-model="form[field.name]" autofocus @keyup.enter="submitData()" />
      </q-card-section>
      <q-card-actions align="right">
        <q-btn flat :label="t('cancel')" color="primary" v-close-popup @click="cancelSubmit()" />
        <q-btn flat :label="t('submit')" color="primary" v-close-popup @click="submitData()" />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useQuasar } from 'quasar'
import { useI18n } from 'vue-i18n'
import { get, post } from 'boot/axios'
import { useTokenStore } from 'stores/token'
import { useLanguageStore } from 'stores/language'
import emitter from 'boot/bus.js'

const props = defineProps({
  apiBase: { type: String, required: true },
  entityTitle: { type: String, default: '' },
  columns: { type: Array, required: true },
  formFields: { type: Array, required: true },
  searchFields: { type: Array, required: true },
})

const { t } = useI18n()
const $q = useQuasar()
const tokenStore = useTokenStore()
const langStore = useLanguageStore()

const token = computed(() => tokenStore.token)
const rows = ref([])
const search = ref('')
const formData = ref(false)
const form = ref({})
const mode = ref('create')
const rowsCount = ref(0)

const pagination = ref({
  sortBy: 'updated_time',
  descending: false,
  page: 1,
  rowsPerPage: 30,
  rowsNumber: 30
})

const pagesNumber = computed(() => {
  if (token.value !== '') {
    return Math.ceil(rowsCount.value / pagination.value.rowsPerPage)
  }
  return 0
})

const screenHeight = ref(`${$q.screen.height * 0.73}px`)
const screenWidth = ref(`${$q.screen.width * 0.825}px`)
const cardBackground = ref($q.dark.isActive ? '#121212' : '#ffffff')

function buildSearchParams() {
  if (!search.value) return '{}'
  const conditions = {}
  for (const f of props.searchFields) {
    conditions[`data__${f}__icontains`] = search.value
  }
  return JSON.stringify(conditions)
}

function onRequest(p) {
  let requestData = p || { pagination: pagination.value }
  get({
    url: `${props.apiBase}/`,
    params: {
      params: buildSearchParams(),
      page: requestData.pagination.page,
      max_page: requestData.pagination.rowsPerPage
    }
  }).then((res) => {
    rows.value = (res.results || []).map(r => {
      const d = r.data || {}
      return { ...r, ...d }
    })
    rowsCount.value = res.count
  }).catch((err) => {
    $q.notify({ type: 'error', message: err?.detail || err?.message || 'Error' })
    $q.loading.hide()
  })
  pagination.value = requestData.pagination
}

function createData() {
  mode.value = 'create'
  form.value = {}
  for (const f of props.formFields) {
    form.value[f.name] = ''
  }
  formData.value = true
}

function editData(e) {
  mode.value = 'update'
  form.value = { ...rows.value[e] }
  formData.value = true
}

function deleteData(e) {
  $q.dialog({
    dark: $q.dark.isActive,
    title: t('delete'),
    message: t('confirmnotice'),
    cancel: true,
  }).onOk(() => {
    post(`${props.apiBase}/delete/`, { id: rows.value[e].id }).then(() => {
      onRequest()
    }).catch((err) => {
      $q.notify({ type: 'error', message: err?.detail || err?.message || 'Error' })
      $q.loading.hide()
    })
  })
}

function cancelSubmit() {
  formData.value = false
  form.value = {}
}

async function submitData() {
  const dataObj = {}
  for (const f of props.formFields) {
    dataObj[f.name] = form.value[f.name] || ''
  }
  const payload = mode.value === 'create'
    ? { data: dataObj }
    : { id: form.value.id, data: dataObj }

  const url = mode.value === 'create'
    ? `${props.apiBase}/create/`
    : `${props.apiBase}/update/`

  await post(url, payload).then(() => {
    onRequest()
    cancelSubmit()
  }).catch((err) => {
    $q.notify({ type: 'error', message: err?.detail || err?.message || 'Error' })
    $q.loading.hide()
  })
}

onMounted(() => {
  listenToEvent()
  onRequest()
})

watch(() => $q.dark.isActive, (val) => {
  cardBackground.value = val ? '#121212' : '#ffffff'
})

function listenToEvent() {
  emitter.on('needLogin', (payload) => {
    if (payload) {
      rows.value = []
      search.value = ''
      rowsCount.value = 0
    }
  })
}

watch(() => langStore.langData, (val) => {
  if (val) { onRequest() }
})
</script>
