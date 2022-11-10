import { userlist } from "@/services/user";
export default {
  namespaced: true,
  state: {
    user: undefined,
    permissions: null,
    roles: null,
    routesConfig: null,
    userlist: []
  },
  getters: {
    user: state => {
      if (!state.user) {
        try {
          const user = localStorage.getItem(process.env.VUE_APP_USER_KEY)
          state.user = JSON.parse(user)
        } catch (e) {
          console.error(e)
        }
      }
      return state.user
    },
    permissions: state => {
      if (!state.permissions) {
        try {
          const permissions = localStorage.getItem(process.env.VUE_APP_PERMISSIONS_KEY)
          state.permissions = JSON.parse(permissions)
          state.permissions = state.permissions ? state.permissions : []
        } catch (e) {
          console.error(e.message)
        }
      }
      return state.permissions
    },
    roles: state => {
      if (!state.roles) {
        try {
          const roles = localStorage.getItem(process.env.VUE_APP_ROLES_KEY)
          state.roles = JSON.parse(roles)
          state.roles = state.roles ? state.roles : []
        } catch (e) {
          console.error(e.message)
        }
      }
      return state.roles
    },
    routesConfig: state => {
      if (!state.routesConfig) {
        try {
          const routesConfig = localStorage.getItem(process.env.VUE_APP_ROUTES_KEY)
          state.routesConfig = JSON.parse(routesConfig)
          state.routesConfig = state.routesConfig ? state.routesConfig : []
        } catch (e) {
          console.error(e.message)
        }
      }
      return state.routesConfig
    },
    userlist: state => {
      return state.userlist
    }
  },
  mutations: {
    setUser(state, user) {
      state.user = user
      localStorage.setItem(process.env.VUE_APP_USER_KEY, JSON.stringify(user))
    },
    setPermissions(state, permissions) {
      state.permissions = permissions
      localStorage.setItem(process.env.VUE_APP_PERMISSIONS_KEY, JSON.stringify(permissions))
    },
    setRoles(state, roles) {
      state.roles = roles
      localStorage.setItem(process.env.VUE_APP_ROLES_KEY, JSON.stringify(roles))
    },
    setRoutesConfig(state, routesConfig) {
      state.routesConfig = routesConfig
      localStorage.setItem(process.env.VUE_APP_ROUTES_KEY, JSON.stringify(routesConfig))
    },
    setUserList(state, userlist) {
      state.userlist = userlist;
    }
  },
  actions: {
    getAllUserlist({ commit }) {
      return new Promise((resolve, reject) => {
        userlist({
          pagination: {
            pageSize: 10000,
            sortBy: "",
            page: 1,
          },
          keyword: "",
        })
          .then(res => {
            if (res && res.errcode === 0) {
              const { list } = res.data ?? {};
              if (Array.isArray(list)) {
                commit("setUserList", list)
                resolve()
              }
            } else {
              reject()
            }
          })
          .catch(() => {
            reject()
          })
      })
    }
  }
}
