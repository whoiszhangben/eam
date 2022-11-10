import { orglist } from "@/services/organization";
import { ArrayToTree, ArrayToTree2 } from "@/utils/util";
export default {
  namespaced: true,
  state: {
    selectOrg: {},
    orgTree: [],
    orgList: [],
    deptList: [],
    filterOrgTree: []
  },
  getters: {
    selectOrg(state) {
      return state.selectOrg
    },
    orgTree(state) {
      return state.orgTree
    },
    filterOrgTree(state) {
      return state.filterOrgTree
    },
    orgList(state) {
      return state.orgList
    },
    deptList(state) {
      return state.deptList
    }
  },
  mutations: {
    setSelectOrg(state, org) {
      state.selectOrg = org;
    },
    setOrgTree(state, orgTree) {
      state.orgTree = orgTree
    },
    setOrgList(state, orgList) {
      state.orgList = orgList
    },
    setDeptList(state, deptList) {
      state.deptList = deptList
    },
    setFilterOrgTree(state, orgTree) {
      state.filterOrgTree = orgTree
    }
  },
  actions: {
    getOrganizations({ commit }) {
      return new Promise((resolve, reject) => {
        orglist()
          .then(res => {
            if (res && res.errcode === 0) {
              let orglist = res.data.list;
              commit("setOrgList", orglist);
              let orgtree = ArrayToTree(orglist, null);
              commit("setOrgTree", orgtree);
              let filterOrgTree = ArrayToTree2(orglist, null);
              commit("setFilterOrgTree", filterOrgTree);
              let deptMap = new Map();
              let deptList = [];
              orglist.forEach((item) => {
                if (item.isdept) {
                  deptMap.set(item.code, item.name);
                }
              });
              for (let [key, value] of deptMap) {
                deptList.push({
                  id: key,
                  name: value,
                });
              }

              console.log("deptList:", deptList);
              commit("setDeptList", deptList)
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
