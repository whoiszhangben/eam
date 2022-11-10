import { VENDORADD, VENDORDEL, VENDOREDIT, VENDORQUERY } from '@/services/api'
import { request, METHOD } from '@/utils/request'

export async function vendorlist(params) {
    return request(VENDORQUERY, METHOD.POST, params)
}

export async function vendoradd(params) {
    return request(VENDORADD, METHOD.POST, params)
}

export async function vendoredit(params) {
    return request(VENDOREDIT, METHOD.POST, params)
}

export async function vendordel(params) {
    return request(VENDORDEL, METHOD.POST, params)
}

export default {
    vendorlist,
    vendoradd,
    vendoredit,
    vendordel
}
