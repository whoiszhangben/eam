import { GOODSIMPORT, GOODSADD, GOODSDEL, GOODSEDIT, GOODSQUERY, PRINT, PRINTALL, REPAIRQUERY, REPAIRADD, SCANQUERY, GOODSEXPORT, Statistic, FLOWQUERY, PRINTCLIENTS, REPAIREXPORT, DISTRIBUTE, GOODSTEMPLATE } from '@/services/api'
import { request, METHOD } from '@/utils/request'

export async function importGoodsList(params) {
    return request(GOODSIMPORT, METHOD.POST, params, {
        'Content-type': 'multipart/form-data'
    })
}
export async function exportGoods(params) {
    return request(GOODSEXPORT, METHOD.POST, params, {
        responseType: "blob"
    })
}
export async function getGoodslist(params) {
    return request(GOODSQUERY, METHOD.Get, params)
}
export async function goodslist(params) {
    return request(GOODSQUERY, METHOD.POST, params)
}
export async function goodsadd(params) {
    return request(GOODSADD, METHOD.POST, params)
}
export async function goodsedit(params) {
    return request(GOODSEDIT, METHOD.POST, params)
}
export async function goodsdel(params) {
    return request(GOODSDEL, METHOD.POST, params)
}
export async function print(params) {
    return request(PRINT, METHOD.POST, params)
}
export async function printAll(params) {
    return request(PRINTALL, METHOD.POST, params)
}
export async function repairlist(params) {
    return request(REPAIRQUERY, METHOD.POST, params)
}
export async function repairrecordadd(params) {
    return request(REPAIRADD, METHOD.POST, params)
}
export async function repairlist2(params) {
    return request(SCANQUERY, METHOD.POST, params)
}
export async function statistic(params) {
    return request(Statistic, METHOD.POST, params)
}
export async function flowquery(params) {
    return request(FLOWQUERY, METHOD.POST, params)
}
export async function printlist(params) {
    return request(PRINTCLIENTS, METHOD.POST, params)
}
export async function repairexport(params) {
    return request(REPAIREXPORT, METHOD.POST, params, {
        responseType: "blob"
    })
}
export async function distributestatistic(params) {
    return request(DISTRIBUTE, METHOD.POST, params)
}
export async function exportTemplate(params) {
    return request(GOODSTEMPLATE, METHOD.POST, params, {
        responseType: "blob"
    })
}

export default {
    importGoodsList,
    getGoodslist,
    goodslist,
    goodsadd,
    goodsedit,
    goodsdel,
    print,
    printAll,
    repairlist,
    repairrecordadd,
    repairlist2,
    statistic,
    flowquery,
    printlist,
    repairexport,
    distributestatistic,
    exportTemplate
}
