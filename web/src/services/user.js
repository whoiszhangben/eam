import { LOGIN, USERLIST, USERADD, USERDEL, USEREDIT, USERPWDEdit } from '@/services/api'
import { request, METHOD, removeAuthorization } from '@/utils/request'

/**
 * 登录服务
 * @param account 账户名
 * @param password 账户密码
 * @returns {Promise<AxiosResponse<T>>}
 */
export async function login(account, password) {
  return request(LOGIN, METHOD.POST, {
    account: account,
    password: password,
    clientType: 1,
  })
}

export async function userlist(params) {
  return request(USERLIST, METHOD.POST, params)
}

export async function useradd(params) {
  return request(USERADD, METHOD.POST, params)
}

export async function userdel(params) {
  return request(USERDEL, METHOD.POST, params)
}

export async function useredit(params) {
  return request(USEREDIT, METHOD.POST, params)
}

export async function userpwdmodify(params) {
  return request(USERPWDEdit, METHOD.POST, params)
}

/**
 * 退出登录
 */
export function logout() {
  localStorage.removeItem(process.env.VUE_APP_ROUTES_KEY)
  localStorage.removeItem(process.env.VUE_APP_PERMISSIONS_KEY)
  localStorage.removeItem(process.env.VUE_APP_ROLES_KEY)
  removeAuthorization()
}
export default {
  login,
  userlist,
  useradd,
  userdel,
  logout
}
