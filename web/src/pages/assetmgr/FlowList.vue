<template>
  <a-card :style="{ minHeight }">
    <a-spin :spinning="spinning">
      <standard-table
        :columns="columns"
        :dataSource="dataSource"
        :pagination="false"
      >
        <div slot="index" slot-scope="{ text, record, index }">
          {{ index + 1 }}
        </div>
        <div slot="goodsId">
          {{ goodsInfo.name }}
        </div>
        <div slot="state" slot-scope="{ text }">
          {{ getAssetState(text, 2) }}
        </div>
        <div slot="accountId" slot-scope="{ text }">
          {{ getAccount(text) }}
        </div>
        <div slot="createTime" slot-scope="{ text }">
          {{ momentFormat(text) }}
        </div>
      </standard-table>
    </a-spin>
  </a-card>
</template>
    
      <script>
import StandardTable from "@/components/table/StandardTable";
import { flowquery } from "@/services/goods";
import moment from "moment";
import { mapActions, mapGetters, mapState } from "vuex";
import { getAssetState } from "@/utils/util";
const columns = [
  {
    title: "序号",
    dataIndex: "id",
    scopedSlots: { customRender: "index" },
  },
  {
    title: "资产名称",
    dataIndex: "goodsId",
    scopedSlots: { customRender: "goodsId" },
  },
  {
    title: "资产状态",
    dataIndex: "state",
    scopedSlots: { customRender: "state" },
  },
  {
    title: "操作人",
    dataIndex: "accountId",
    scopedSlots: { customRender: "accountId" },
  },
  {
    title: "当时使用人",
    dataIndex: "user",
  },
  {
    title: "流水时间",
    dataIndex: "createTime",
    scopedSlots: { customRender: "createTime" },
  },
  {
    title: "描述",
    dataIndex: "description",
  },
];

export default {
  name: "FlowList",
  components: {
    StandardTable,
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
    ...mapState("setting", ["lang"]),
    ...mapGetters("account", ["userlist"]),
    ...mapState("setting", ["pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
  },
  data() {
    return {
      advanced: true,
      columns: columns,
      dataSource: [],
      goodsInfo: {
        id: 0,
        name: "",
      },
      spinning: true,
    };
  },
  mounted() {
    this.getAllUserlist().then(() => {
      this.getData();
    });
  },
  methods: {
    ...mapActions("account", ["getAllUserlist"]),
    getAssetState,
    getData() {
      let goodsId = Number(this.$route.params.id);
      let goodsName = this.$route.params.name;
      this.goodsInfo.id = goodsId;
      this.goodsInfo.name = goodsName;
      flowquery({
        goodsId,
      })
        .then((res) => {
          if (res) {
            if (res.errcode === 0) {
              res.data.sort((a, b) => {
                let atime = new Date(a.createTime).getTime();
                let btime = new Date(b.createTime).getTime();
                if (atime > btime) {
                  return -1;
                } else if (atime < btime) {
                  return 1;
                } else {
                  return 0;
                }
              });
              this.dataSource = res.data;
            } else {
              this.$message.error(res.errmsg);
            }
          } else {
            this.$message.error("服务异常， 请联系管理员");
          }

          this.spinning = false;
        })
        .catch((err) => {
          this.$message.error(err.message);
          this.spinning = false;
        });
    },
    deleteRecord(key) {
      console.log(key);
    },
    toggleAdvanced() {
      this.advanced = !this.advanced;
    },
    remove() {},
    momentFormat(date, type = "YYYY-MM-DD HH:mm:ss") {
      return moment(date).format(type);
    },
    getAccount(userId) {
      let currentUser = this.userlist.find((x) => x.id === Number(userId));
      if (currentUser) {
        return currentUser.name;
      } else {
        return "--";
      }
    },
  },
};
</script>
    
      <style lang="less" scoped>
/deep/ .ant-form-vertical .ant-form-item-label,
.ant-col-24.ant-form-item-label,
.ant-col-xl-24.ant-form-item-label {
  margin-right: 10px;
  text-align: right;
}
.assetDivider {
  margin: 0 0 24px;
  & /deep/ .ant-divider,
  .ant-divider-vertical {
    top: 0;
  }
}
.operator {
  margin-bottom: 10px;
}
</style>
    