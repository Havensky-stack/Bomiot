<template>
  <div class="flex flex-center bg-grey-2" style="min-height: 100vh;">
    <q-card style="width: 400px; max-width: 90vw;" class="q-pa-md">
      <q-card-section class="text-h5 text-center">登录 Bomiot</q-card-section>

      <q-card-section>
        <q-form @submit="onLogin">
          <q-input
            v-model="username"
            label="用户名"
            filled
            lazy-rules
            :rules="[ val => val && val.length > 0 || '请输入用户名']"
          />
          <q-input
            v-model="password"
            label="密码"
            type="password"
            filled
            class="q-mt-md"
            lazy-rules
            :rules="[ val => val && val.length > 0 || '请输入密码']"
          />
          <q-btn
            label="登 录"
            type="submit"
            color="primary"
            class="full-width q-mt-lg"
            :loading="loading"
          />
        </q-form>
      </q-card-section>

      <q-card-section class="text-center">
        <q-btn flat label="没有账号？去注册" to="/register" />
      </q-card-section>
    </q-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { api } from 'src/boot/axios'

const router = useRouter()
const username = ref('')
const password = ref('')
const loading = ref(false)

async function onLogin() {
  loading.value = true
  try {
    const res = await api.post('/api/token/', {
      username: username.value,
      password: password.value
    })
    localStorage.setItem('access_token', res.data.access)
    localStorage.setItem('refresh_token', res.data.refresh)
    router.push('/warehouse')
  } catch (err) {
    alert('登录失败：' + (err.response?.data?.detail || err.message))
  } finally {
    loading.value = false
  }
}
</script>