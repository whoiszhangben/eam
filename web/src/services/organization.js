import {ORGQUERY, ORGADD, ORGEDIT, ORGDEL} from '@/services/api'
import {request, METHOD} from '@/utils/request'

export async function orglist() {
    return request(ORGQUERY, METHOD.GET)
}

export async function orgadd(params) {
    return request(ORGADD, METHOD.POST, params)
}

export async function orgedit(params) {
    return request(ORGEDIT, METHOD.POST, params)
}

export async function orgdel(params) {
    return request(ORGDEL, METHOD.POST, params)
}

export default {
    orglist,
    orgadd,
    orgedit,
    orgdel
}