import { GSORTLIST, GSORTADD, GSORTEDIT, GSORTDEL, CHILDGSORTADD, CHILDGSORTEDIT, CHILDGSORTQUERY, CHILDGSORTDEL } from '@/services/api'
import { request, METHOD } from '@/utils/request'

export async function categorylist(params) {
    return request(GSORTLIST, METHOD.POST, params)
}

export async function categoryadd(params) {
    return request(GSORTADD, METHOD.POST, params)
}

export async function categoryedit(params) {
    return request(GSORTEDIT, METHOD.POST, params)
}

export async function categorydel(params) {
    return request(GSORTDEL, METHOD.POST, params)
}

export async function childcatlist(params) {
    return request(CHILDGSORTQUERY, METHOD.POST, params)
}

export async function childcatadd(params) {
    return request(CHILDGSORTADD, METHOD.POST, params)
}

export async function childcatedit(params) {
    return request(CHILDGSORTEDIT, METHOD.POST, params)
}

export async function childcatdel(params) {
    return request(CHILDGSORTDEL, METHOD.POST, params)
}

export default {
    categorylist,
    categoryadd,
    categoryedit,
    categorydel,
    childcatlist,
    childcatedit,
    childcatdel,
    childcatadd
}
