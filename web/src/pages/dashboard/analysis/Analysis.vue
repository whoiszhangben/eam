<template>
  <div class="analysis">
    <a-row style="margin: 20px 0 15px" type="flex" justify="space-between">
      <a-col :sm="24" :md="12" :xl="5">
        <chart-card
          :loading="loading"
          title="资产总数"
          :value="statistic.count | formatNum"
          unit="个"
          :imgUrl="require('@/assets/img/assets.png')"
        >
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="5">
        <chart-card
          :loading="loading"
          title="使用中资产数"
          :value="statistic.use"
          unit="个"
          :imgUrl="require('@/assets/img/zhiyong.png')"
        >
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="5">
        <chart-card
          :loading="loading"
          title="闲置资产数"
          :value="statistic.free | formatNum"
          unit="个"
          :imgUrl="require('@/assets/img/xianzhi.png')"
        >
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="5">
        <chart-card
          :loading="loading"
          title="报废遗失数"
          :value="statistic.scrapLost | formatNum"
          unit="个"
          :imgUrl="require('@/assets/img/baofei.png')"
        >
        </chart-card>
      </a-col>
      <a-col :sm="24" :md="12" :xl="5">
        <chart-card
          :loading="loading"
          title="资产总金额"
          :value="statistic.priceToal | formatNum"
          unit="元"
          :imgUrl="require('@/assets/img/amount.png')"
        >
        </chart-card>
      </a-col>
    </a-row>
    <a-row style="margin: 0 -12px">
      <a-col
        style="padding: 0 12px"
        :xl="8"
        :lg="24"
        :md="24"
        :sm="24"
        :xs="24"
      >
        <a-card :loading="loading" :bordered="false" title="基地资产占比">
          <org-asset-ratio :sourceData="baseOrg"></org-asset-ratio>
        </a-card>
      </a-col>
      <a-col
        style="padding: 0 12px"
        :xl="16"
        :lg="24"
        :md="24"
        :sm="24"
        :xs="24"
      >
        <a-card :loading="loading" :bordered="false" title="部门占比">
          <org-asset-ratio2 :sourceData="effectiveData"></org-asset-ratio2>
        </a-card>
      </a-col>
    </a-row>
    <a-row style="margin-top: 12px">
      <a-col :xl="24" :lg="24" :md="24" :sm="24" :xs="24">
        <a-card :loading="loading" :bordered="true" title="资产购买对比">
          <curve-area :sourceData="monthTotal" />
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script>
import ChartCard from "@/components/card/ChartCard";
import OrgAssetRatio from "./OrgAssetRatio";
import OrgAssetRatio2 from "./OrgAssetRatio2";
import CurveArea from "./CurveArea";
import { statistic } from "@/services/goods";
import { EventBus } from "@/utils/eventBus";

export default {
  name: "Analysis",
  i18n: require("./i18n"),
  data() {
    return {
      loading: true,
      statistic: {
        baseOrg: [],
        count: 0,
        free: 0,
        priceToal: 0,
        scrapLost: 0,
        use: 0,
        monthTotal: [],
      },
      tmpMonthTotal: [],
    };
  },
  created() {
    this.getData();
    EventBus.$on("refreshChartData", () => {
      this.getData();
    });
  },
  computed: {
    baseOrg() {
      let arr = [];
      if (Array.isArray(this.statistic.baseOrg)) {
        this.statistic.baseOrg.forEach((x) => {
          arr.push({
            item: x.title,
            count: x.total,
          });
        });
      }
      console.log("baseOrg:", arr);
      return arr;
    },
    effectiveData() {
      let arr = [];
      if (Array.isArray(this.statistic.deptTotal)) {
        this.statistic.deptTotal.forEach((x) => {
          arr.push({
            type: "部门资产金额",
            title: x.title,
            total: x.total,
          });
        });
      }
      if (Array.isArray(this.statistic.deptRepairTotal)) {
        this.statistic.deptRepairTotal.forEach((x) => {
          arr.push({
            type: "部门维修费用",
            title: x.title,
            total: x.total,
          });
        });
      }
      return arr;
    },
    monthTotal() {
      if (Array.isArray(this.tmpMonthTotal)) {
        return this.tmpMonthTotal.map((item) => {
          return {
            ...item,
            alias: "总资产",
          };
        });
      } else {
        return [];
      }
    },
  },
  components: {
    ChartCard,
    OrgAssetRatio,
    OrgAssetRatio2,
    CurveArea,
  },
  filters: {
    //格式化字符串
    formatNum(num) {
      // 如果val小于1000, 整数直接返回，小数转两位
      if (num < 1000) {
        if (Number.isInteger(num)) {
          return num.toString();
        } else {
          return num.toFixed(2);
        }
      } else if (num < 10000) {
        if (Number.isInteger(num)) {
          return (num + "").replace(/\d{1,3}(?=(\d{3})+(\.\d*)?$)/g, "$&,");
        } else {
          return (num.toFixed(2) + "").replace(
            /\d{1,3}(?=(\d{3})+(\.\d*)?$)/g,
            "$&,"
          );
        }
      } else if (num < 100000000) {
        return `${(num / 10000).toFixed(2)}万`;
      } else {
        return `${(num / 100000000).toFixed(2)}亿`;
      }
    },
  },
  methods: {
    getData() {
      statistic()
        .then((res) => {
          if (res) {
            if (res.errcode === 0) {
              this.statistic = res.data;
              if (Array.isArray(this.statistic.monthTotal)) {
                this.tmpMonthTotal = this.statistic.monthTotal.reverse();
              }
            } else {
              this.$message.error(res.errmsg);
            }
          } else {
            this.$message.error("服务异常， 请联系管理员");
          }
          this.loading = false;
        })
        .catch((err) => {
          this.$message.error(err.message);
          this.loading = false;
        });
    },
  },
  destroyed() {
    EventBus.$off("refreshChartData", () => {
      console.log("refreshData teardown");
    });
  },
};
</script>

<style lang="less" scoped>
.extra-wrap {
  .extra-item {
    display: inline-block;
    margin-right: 24px;
    a:not(:first-child) {
      margin-left: 24px;
    }
  }
}
@media screen and (max-width: 992px) {
  .extra-wrap .extra-item {
    display: none;
  }
}
@media screen and (max-width: 576px) {
  .extra-wrap {
    display: none;
  }
}
/deep/ .ant-card-head-title {
  font-weight: 700;
  font-size: 14px;
}
/deep/ .ant-col-xl-5 {
  width: 19%;
}
</style>
