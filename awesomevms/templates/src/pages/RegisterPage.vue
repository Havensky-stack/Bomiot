<template>
  <div class="flex flex-center bg-grey-2" style="min-height: 100vh;">
    <q-card style="width: 400px; max-width: 90vw;" class="q-pa-md">
      <q-card-section class="text-h5 text-center">注册新账号</q-card-section>

      <q-card-section>
        <q-form @submit="onRegister">
          <q-input v-model="username" label="用户名" filled lazy-rules :rules="[ val => !!val || '必填' ]" />
          <q-input v-model="email" label="邮箱" type="email" filled class="q-mt-md" />
          <q-input v-model="password" label="密码" type="password" filled class="q-mt-md" lazy-rules :rules="[ val => val.length >= 6 || '至少6位密码' ]" />
          <q-input v-model="password2" label="确认密码" type="password" filled class="q-mt-md" lazy-rules :rules="[ val => val === password || '两次密码不一致' ]" />

          <q-btn label="注 册" type="submit" color="primary" class="full-width q-mt-lg" :loading="loading" />
        </q-form>
      </q-card-section>

      <q-card-section class="text-center">
        <q-btn flat label="已有账号？去登录" to="/login" />
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
const email = ref('')
const password = ref('')
const password2 = ref('')
const loading = ref(false)

async function onRegister() {
  loading.value = true
  try {
    await api.post('/api/auth/register/', {
      username: username.value,
      email: email.value,
      password: password.value
    })
    alert('注册成功，请登录')
    router.push('/login')
  } catch (err) {
    alert('注册失败：' + (err.response?.data?.detail || err.message))
  } finally {
    loading.value = false
  }
}
</script>