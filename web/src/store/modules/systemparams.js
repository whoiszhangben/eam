import { paramsquery } from "@/services/sysparams";

export default {
    namespaced: true,
    state: {
        systemparams: {}
    },
    getters: {
        systemparams(state) {
            return state.systemparams
        }
    },
    mutations: {
        setSystemParams(state, params) {
            state.systemparams = params
        }
    },
    actions: {
        getSystemParams({ commit }, payload) {
            paramsquery(payload)
                .then(res => {
                    if (res && res.errcode == 0) {
                        commit('setSystemParams', res.data);
                    }
                })
        }
    }
}