<template>
  <q-layout view="hHh lpR fFf">
    <q-header :class="[$q.dark.isActive ? 'bg-grey-10' : 'main-headers-sun']">
      <transition
        appear
        enter-active-class="animated fadeIn slower delay-10s"
        leave-active-class="animated fadeOut slower delay-10s">
      <q-toolbar>
        <q-btn dense flat round icon="menu" v-show="leftDrawerStore.leftDrawerMenu" @click="leftDrawerStore.toggleleftDrawer" />
        <q-toolbar-title @click="$router.push('/')">
          <q-avatar>
            <img src="/icons/logo.png" :alt="appNameStore.appName + ' Logo'" />
          </q-avatar>
            {{ appNameStore.appName }} Team©
        </q-toolbar-title>

        <LangChoice />
        <DarkMode />
        <q-btn-group unelevated style="margin-left: 25px">
          <q-btn v-show="tokenStore.token === ''" :label="t('login')" @click="loginForm = true"/>
          <q-btn v-show="tokenStore.token !== ''" :label="t('logout')" @click="logOuts()"/>
        </q-btn-group>
        <q-btn dense flat round icon="menu" v-show="rightDrawerStore.rightDrawerMenu" @click="rightDrawerStore.toggleRightDrawer" />
      </q-toolbar>
      </transition>
      <TabList />
    </q-header>

    <q-drawer
      v-model="leftDrawerStore.leftDrawerOpen"
      side="left"
      :breakpoint="500"
      :class="{'drawer-background-dark text-white': $q.dark.isActive}">
        <q-list padding>
          <MenuLink />
        </q-list>
    </q-drawer>

    <q-drawer :class="{'drawer-background-dark': $q.dark.isActive}" v-model="rightDrawerStore.rightDrawerOpen" side="right" style="width: 310px!important">
<!--      write right drawer here -->
    </q-drawer>

    <q-page-container>
        <router-view />
        <q-page-scroller position="bottom-right" :scroll-offset="150" :offset="[18, 18]">
          <q-btn fab icon="keyboard_arrow_up" color="indigo"></q-btn>
        </q-page-scroller>
    </q-page-container>
  </q-layout>
  <q-dialog v-model="loginForm">
    <q-card style="min-width: 350px">
      <q-card-section class="row items-center q-pb-none">
        <div class="text-h6">{{ t('login') }}</div>
        <q-space />
        <q-btn icon="close" @click="cancelLogin()" flat round dense v-close-popup />
      </q-card-section>
      <q-card-section>
        <q-input autofocus :label="t('username')" v-model="loginData.username"></q-input>
        <q-input v-model="loginData.password" :type="isPwd ? 'password' : 'text'" :label="t('password')">
        <template v-slot:append>
          <q-icon
            :name="isPwd ? 'visibility_off' : 'visibility'"
            class="cursor-pointer"
            @click="isPwd = !isPwd"
          />
        </template>
      </q-input>
      </q-card-section>
      <q-card-actions align="right" class="text-primary">
        <q-btn flat :label="t('cancel')" @click="cancelLogin()" v-close-popup />
        <q-btn flat :label="t('submit')" @click="submitLogin()" v-close-popup />
      </q-card-actions>
    </q-card>
  </q-dialog>
</template>


<script setup>
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useAppNameStore } from 'stores/appName'
import { userightDrawerStore } from "stores/rightDrawer"
import { useleftDrawerStore } from "stores/leftDrawer"
import { useTokenStore } from "stores/token"
import { useLanguageStore } from 'stores/language'
import { useI18n } from "vue-i18n"
import { useQuasar } from "quasar"
import { useRouter } from 'vue-router'
import { post } from 'boot/axios'
import DarkMode from 'components/dark/DarkMode.vue'
import LangChoice from 'components/lang/LangChoice.vue'
import TabList from 'components/TabList.vue'
import MenuLink from 'components/MenuLink.vue'
import emitter from 'boot/bus';

const { t } = useI18n()
const $q = useQuasar()
const $router = useRouter()
const appNameStore = useAppNameStore()
const rightDrawerStore = userightDrawerStore()
const leftDrawerStore = useleftDrawerStore()
const tokenStore = useTokenStore()
const langStore = useLanguageStore()

const loginForm = ref(false)
const isPwd = ref(true)
const loginData = ref({
  username: '',
  password: ''
})

function cancelLogin () {
  loginData.value = {
    username: '',
    password: ''
  }
}

async function submitLogin () {
  if (loginData.value.username !== '' && loginData.value.password !== '') {
    await post('login/', loginData.value).then((res) =>{
      if (!res.login) {
        tokenStore.tokenChange(res.token)
        emitter.emit('needLogin', false)
        cancelLogin()
      }
    }).catch((err) =>{
      console.log(err)
    })
  } else {
    $q.notify({
      type: 'warning',
      message: t('usererror')
    })
  }
}

function logOuts () {
  tokenStore.tokenChange('')
  $q.notify({
    type: 'info',
    message: t('logoutnotice')
  })
}

onMounted(() => {
  tokenStore.tokenCheck()
  listenToEvent()
})

onBeforeUnmount(() => {
  emitter.off('needLogin')
})

function listenToEvent() {
  emitter.on('needLogin', (payload) => {
    if (payload) {
      tokenStore.tokenChange('')
    }
  })
}

watch(() => langStore.langData, val => {
  if (val) {
    return
  }
})

</script>