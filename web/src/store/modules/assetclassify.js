import {
    categorylist
} from "@/services/category";
export default {
    namespaced: true,
    state: {
        classifylist: []
    },
    getters: {
        classifylist(state) {
            return state.classifylist
        },
    },
    mutations: {
        setClassifylist(state, list) {
            console.log("当前获取classifylist:", list);
            state.classifylist = list;
        }
    },
    actions: {
        getAllClassifylist({ commit }) {
            return new Promise((resolve, reject) => {
                categorylist({
                    pagination: {
                        pageSize: 10000,
                        sortBy: "",
                        page: 1,
                    },
                    keyword: "",
                })
                    .then(res => {
                        if (res && res.errcode === 0) {
                            commit('setClassifylist', res.data.list)
                            resolve()
                        } else {
                            reject()
                        }
                    })
                    .catch(err => {
                        reject(err)
                    })
            })
        }
    }
}
