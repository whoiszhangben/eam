<template>
  <a-card :style="{ minHeight }">
    <a-spin :spinning="spinning">
      <div>
        <a-row style="margin-bottom: 15px">
          <a-col :span="4">
            <a-input placeholder="输入IP搜索" v-model="searchText"></a-input>
          </a-col>
          <a-col :span="14">
            <a-button type="primary" @click="search" style="margin-left: 20px"
              >查询</a-button
            >
            <a-button @click="reset" style="margin-left: 20px">重置</a-button>
          </a-col>
        </a-row>
        <standard-table
          :columns="columns"
          :dataSource="dataSource"
          :pagination="{
            ...pagination,
            onChange: onPageChange,
          }"
        >
          <div slot="accountName" slot-scope="{ text, record }">
            {{ getAccount(record.accountId).name }}
          </div>
          <div slot="accountId" slot-scope="{ text, record }">
            {{ getAccount(record.accountId).account }}
          </div>
          <div slot="clientType" slot-scope="{ text }">
            {{ getClientType(text) }}
          </div>
          <div slot="ctime" slot-scope="{ text }">
            {{ momentFormat(text) }}
          </div>
          <div slot="oprType" slot-scope="{ text }">
            {{ getOprType(text) }}
          </div>
          <div slot="opt" slot-scope="{ text }">
            {{ getOpt(text) }}
          </div>
        </standard-table>
      </div>
    </a-spin>
  </a-card>
</template>
  
    <script>
import StandardTable from "@/components/table/StandardTable";
// import UserModal from '@/components/dialog/userModal'
import { systemlog } from "@/services/sysparams";
import moment from "moment";
import { enums } from "@/utils/enum";
import { mapState, mapGetters, mapActions } from "vuex";
const columns = [
  {
    title: "用户姓名",
    dataIndex: "accountName",
    with: 150,
    scopedSlots: { customRender: "accountName" },
  },
  {
    title: "用户账号",
    dataIndex: "accountId",
    with: 150,
    scopedSlots: { customRender: "accountId" },
  },
  {
    title: "客户端类型",
    dataIndex: "clientType",
    with: 150,
    scopedSlots: { customRender: "clientType" },
  },
  {
    title: "创建时间",
    dataIndex: "ctime",
    with: 200,
    scopedSlots: { customRender: "ctime" },
  },
  {
    title: "模块",
    dataIndex: "oprType",
    with: 150,
    scopedSlots: { customRender: "oprType" },
  },
  {
    title: "操作",
    dataIndex: "opt",
    with: 150,
    scopedSlots: { customRender: "opt" },
  },
  {
    title: "ip地址",
    dataIndex: "remoteIp",
    with: 200,
    scopedSlots: { customRender: "remoteIp" },
  },
  {
    title: "描述",
    dataIndex: "description",
  },
];

export default {
  name: "SystemLog",
  components: {
    StandardTable,
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
    ...mapState("setting", ["lang", "pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
    ...mapGetters("account", ["userlist"]),
  },
  data() {
    return {
      advanced: true,
      columns: columns,
      dataSource: [],
      selectedRows: [],
      pagination: {
        current: 1,
        pageSize: 10,
        total: 0,
        showTotal: (total) => `共 ${total} 条数据`,
      },
      opType: 0, // 0为新增 1为编辑 2为详情
      visible: false,
      modalData: null,
      spinning: true,
      searchText: "",
      modal: null,
    };
  },
  mounted() {
    if (!this.userlist.length) {
      this.getAllUserlist().then(() => {
        this.getData();
      });
    } else {
      this.getData();
    }
  },
  methods: {
    ...mapActions("account", ["getAllUserlist"]),
    onPageChange(page, pageSize) {
      this.pagination.current = page;
      this.pagination.pageSize = pageSize;
      this.getData();
    },
    getData() {
      this.spinning = true;
      systemlog({
        pagination: {
          pageSize: this.pagination.pageSize,
          sortBy: "",
          page: this.pagination.current,
        },
        keyword: this.searchText,
      })
        .then((res) => {
          this.spinning = false;
          if (res) {
            if (res.errcode === 0) {
              const { list, page, pageSize, total } = res.data ?? {};
              this.dataSource = list ? list : [];
              this.pagination.current = page;
              this.pagination.pageSize = pageSize;
              this.pagination.total = total;
            } else {
              this.$message.error(res.errmsg);
            }
          } else {
            this.$message.error("服务异常， 请联系管理员");
          }
        })
        .catch((err) => {
          this.spinning = false;
          this.$message.error(err.message);
        });
    },
    search() {
      this.pagination.current = 1;
      this.getData();
    },
    reset() {
      this.pagination.current = 1;
      this.searchText = "";
      this.getData();
    },
    momentFormat(date, type = "YYYY-MM-DD HH:mm:ss") {
      return moment(date).format(type);
    },
    getClientType(val) {
      switch (Number(val)) {
        case 1:
          return "PC Web";
        case 2:
          return "Android";
        case 3:
          return "IOS";
        default:
          return "未知客户端";
      }
    },
    getOprType(val) {
      switch (Number(val)) {
        case enums.Module.TABLE_TYPE_REPAIR:
          return "维修";
        case enums.Module.TABLE_TYPE_GOODS:
          return "资产";
        case enums.Module.TABLE_TYPE_ORG:
          return "机构";
        case enums.Module.TABLE_TYPE_ACCOUNT:
          return "账户";
        case enums.Module.TABLE_TYPE_GSORT:
          return "分类";
        case enums.Module.TABLE_TYPE_CHILD_GSORT:
          return "子分类";
        case enums.Module.TABLE_TYPE_VENDOR:
          return "供应商";
        case enums.Module.TABLE_TYPE_CONFIG:
          return "配置文件";
        default:
          return "未知操作";
      }
    },
    getOpt(val) {
      switch (Number(val)) {
        case enums.LogOPType.OPT_TYPE_ADD:
          return "增加";
        case enums.LogOPType.OPT_TYPE_DELETE:
          return "删除";
        case enums.LogOPType.OPT_TYPE_MODIFY:
          return "修改";
        case enums.LogOPType.OPT_TYPE_QUERY:
          return "查询";
        case enums.LogOPType.OPT_TYPE_LOGIN:
          return "登录";
        case enums.LogOPType.OPT_TYPE_IMPORT:
          return "导入";
        case enums.LogOPType.OPT_TYPE_EXPORT:
          return "导出";
        case enums.LogOPType.OPT_TYPE_PRINT:
          return "打印";
        default:
          return "未知操作";
      }
    },
    getAccount(val) {
      let account = this.userlist.find((x) => x.id === Number(val));
      return account;
    },
  },
  destroy() {
    if (this.modal) {
      this.modal.destroy();
    }
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
</style>
  