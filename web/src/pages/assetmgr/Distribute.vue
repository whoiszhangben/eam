<template>
  <a-row :gutter="24">
    <a-col :span="8">
      <a-card :style="{ minHeight }">
        <template slot="title">
          <span class="commonTitle">{{
            `${currentPClassify.name ? currentPClassify.name : "--"} - ${
              currentSubClassify.name ? currentSubClassify.name : "--"
            }
            分布情况统计`
          }}</span>
        </template>
        <org-asset-ratio3 :sourceData="formatSource"></org-asset-ratio3>
      </a-card>
    </a-col>
    <a-col :span="16">
      <a-card :style="{ minHeight }">
        <template slot="title">
          <span class="commonTitle">{{
            `${currentPClassify.name ? currentPClassify.name : "--"} - ${
              currentSubClassify.name ? currentSubClassify.name : "--"
            }
            分布情况`
          }}</span>
        </template>
        <standard-table
          :columns="columns"
          :dataSource="dataSource"
          :pagination="false"
        >
          <div slot="free" slot-scope="{ text, record }">
            {{
              record.total -
              record.useCount -
              record.lossCount -
              record.scrapCount
            }}
          </div>
        </standard-table>
      </a-card>
    </a-col>
  </a-row>
</template>

<script>
import { mapState, mapGetters, mapActions } from "vuex";
import StandardTable from "@/components/table/StandardTable";
import OrgAssetRatio3 from "@/pages/dashboard/analysis/OrgAssetRatio3";
import { distributestatistic } from "@/services/goods";

const columns = [
  {
    title: "部门",
    dataIndex: "title",
  },
  {
    title: "总数量",
    dataIndex: "total",
  },
  {
    title: "闲置数量",
    dataIndex: "free",
    scopedSlots: { customRender: "free" },
  },
  {
    title: "已使用数量",
    dataIndex: "useCount",
  },
  {
    title: "遗失数量",
    dataIndex: "lossCount",
  },
  {
    title: "报废数量",
    dataIndex: "scrapCount",
  },
];
export default {
  name: "Distribute",
  components: {
    StandardTable,
    OrgAssetRatio3,
  },
  data() {
    return {
      columns,
      dataSource: [],
      currentSubClassify: Object.create(null),
      currentPClassify: Object.create(null),
    };
  },
  mounted() {
    if (!this.classifylist.length) {
      this.loadBaseData().then(() => {
        this.getData();
      });
    } else {
      this.getData();
    }
  },
  computed: {
    ...mapState("setting", ["pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
    ...mapGetters("assetclassify", ["classifylist"]),
    formatSource() {
      return this.dataSource.map((item) => {
        return {
          item: item.title,
          count: item.total,
        };
      });
    },
  },
  methods: {
    ...mapActions("organization", ["getOrganizations"]),
    ...mapActions("assetclassify", ["getAllClassifylist"]),
    ...mapActions("vendor", ["getAllVendors"]),
    getData() {
      let subClassifyId = Number(this.$route.params.id);
      let { parent, child } = this.searchTreeBySubnodeId(
        this.classifylist,
        subClassifyId
      );
      this.currentSubClassify = child;
      this.currentPClassify = parent;
      distributestatistic({
        childGsortId: [subClassifyId],
      })
        .then((res) => {
          if (res && res.errcode === 0) {
            this.dataSource = res.data.map((item, index) => {
              return {
                ...item,
                id: index,
              };
            });
            console.log(this.dataSource);
          }
        })
        .catch((err) => {
          console.log(err);
        });
    },
    searchTreeBySubnodeId(nodes, id) {
      for (let i = 0; i < nodes.length; i++) {
        let currentParent = nodes[i];
        if (
          Array.isArray(currentParent.childGsort) &&
          currentParent.childGsort.length > 0
        ) {
          for (let j = 0; j < currentParent.childGsort.length; j++) {
            let currentChild = currentParent.childGsort[j];
            if (currentChild.id === id) {
              return {
                parent: currentParent,
                child: currentChild,
              };
            }
          }
        }
      }
    },
    loadBaseData() {
      // 缓存一些基础数据
      return Promise.all([
        this.getOrganizations(),
        this.getAllClassifylist(),
        this.getAllVendors(),
      ]);
    },
  },
};
</script>

<style lang="less" scoped>
.commonTitle {
  color: #333333;
  font-weight: 700;
  font-size: 14px;
}
</style>