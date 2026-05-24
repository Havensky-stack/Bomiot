import { defineStore } from 'pinia'


export const useTokenStore = defineStore('token', {
  state: () => {
    let initialToken = ''
    try {
      const saved = localStorage.getItem('token')
      if (saved) {
        const parsed = JSON.parse(saved)
        initialToken = parsed.token || ''
      }
    } catch (e) { console.error(e) }
    return { token: initialToken }
  },

  getters: {
    tokenDataGet (state) {
      if (state.token !== '') {
        let strings = state.token.split(".")
        var userinfo = JSON.parse(decodeURIComponent(escape(window.atob(strings[1].replace(/-/g, "+").replace(/_/g, "/")))));
        return userinfo
      } else {
        return state.token
      }
    }
  },

  actions: {
    tokenChange (e) {
      this.token = e
      try {
        if (e) {
          localStorage.setItem('token', JSON.stringify({ token: e }))
        } else {
          localStorage.removeItem('token')
        }
      } catch (err) { console.error(err) }
    },
    tokenCheck() {
      if (this.token !== '') {
        let strings = this.token.split(".")
        var userinfo = JSON.parse(decodeURIComponent(escape(window.atob(strings[1].replace(/-/g, "+").replace(/_/g, "/")))));
        var tokeninit = userinfo.exp - (Date.parse(new Date()) / 1000)
        if (tokeninit <= 0) {
          this.token = ''
          try { localStorage.removeItem('token') } catch (e) { console.error(e) }
        }
      }
    },
    userPermissionGet (e) {
      if (this.token !== '') {
        let strings = this.token.split(".")
        var userinfo = JSON.parse(decodeURIComponent(escape(window.atob(strings[1].replace(/-/g, "+").replace(/_/g, "/")))));
        if (userinfo.admin === true) return true
        return e in userinfo.permission;
      } else {
        return false
      }
    }
  },
  persist: {
    enable: true
  }
})
