import { PARAMSEDIT, PARAMSQUERY, SYSTEMLOG } from '@/services/api'
import { request, METHOD } from '@/utils/request'

export async function paramsquery(params) {
    return request(PARAMSQUERY, METHOD.POST, params)
}

export async function paramsedit(params) {
    return request(PARAMSEDIT, METHOD.POST, params)
}

export async function systemlog(params) {
    return request(SYSTEMLOG, METHOD.POST, params)
}

export default {
    paramsquery,
    paramsedit,
    systemlog
}
