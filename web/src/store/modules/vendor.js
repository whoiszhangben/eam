import { vendorlist } from "@/services/vendor"
export default {
    namespaced: true,
    state: {
        vendorlist: []
    },
    getters: {
        vendorlist(state) {
            return state.vendorlist
        },
    },
    mutations: {
        setVendorlist(state, list) {
            state.vendorlist = list;
        }
    },
    actions: {
        getAllVendors({ commit }) {
            return new Promise((resolve, reject) => {
                vendorlist({
                    pagination: {
                        pageSize: 10000,
                        sortBy: "",
                        page: 1,
                    },
                    keyword: "",
                })
                    .then(res => {
                        if (res && res.errcode === 0) {
                            commit("setVendorlist", res.data.list)
                            resolve()
                        } else {
                            reject()
                        }
                    })
                    .catch(err => {
                        console.log("获取供应商列表信息失败", err.message)
                        reject()
                    })
            })
        }
    }
}
