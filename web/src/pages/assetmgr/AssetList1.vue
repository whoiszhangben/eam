<template>
  <a-card :style="{ minHeight }">
    <a-spin :spinning="spinning">
      <div>
        <a-row style="margin-bottom: 15px">
          <a-col :span="6">
            <a-row class="queryRow">
              <a-col :span="7" class="labelRight">资产类别</a-col>
              <a-col :span="17">
                <a-select
                  v-model="selectclassify"
                  mode="multiple"
                  option-filter-prop="children"
                  :filter-option="filterOption"
                  placeholder="请选择"
                  style="width: 100%"
                  :allowClear="true"
                  :showArrow="true"
                  :maxTagCount="1"
                  :maxTagTextLength="8"
                  :maxTagPlaceholder="
                    () => {
                      return '... +' + (this.selectclassify.length - 1);
                    }
                  "
                >
                  <a-icon slot="suffixIcon" type="down" />
                  <a-select-option
                    v-for="dept in classifylist"
                    :key="dept.id"
                    >{{ dept.name }}</a-select-option
                  >
                </a-select>
              </a-col>
            </a-row>
          </a-col>
          <a-col :span="18">
            <a-button type="primary" @click="search" style="margin-left: 20px"
              >查询</a-button
            >
            <a-button @click="reset" style="margin-left: 20px">重置</a-button>
          </a-col>
        </a-row>
        <standard-table
          :columns="columns"
          :dataSource="dataSource"
          :pagination="{ ...pagination, onChange: onPageChange }"
        >
          <div slot="action" slot-scope="{ text, record }">
            <router-link
              :to="`/assetmgr/assetlist/classifyView/${record.id}`"
              style="margin-right: 8px"
              >查看</router-link
            >
            <router-link
              :to="`/assetmgr/assetlist/distribute/${record.id}`"
              style="margin-right: 8px"
              >分布情况</router-link
            >
          </div>
        </standard-table>
      </div>
    </a-spin>
  </a-card>
</template>

<script>
import { mapState, mapGetters, mapActions } from "vuex";
import StandardTable from "@/components/table/StandardTable";
import { childcatlist } from "@/services/category";
const columns = [
  {
    title: "资产类别",
    dataIndex: "gSortName",
  },
  {
    title: "资产子类别",
    dataIndex: "name",
  },
  {
    title: "总数量",
    dataIndex: "total",
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
  {
    title: "操作",
    scopedSlots: { customRender: "action" },
  },
];

export default {
  name: "AssetList1",
  components: {
    StandardTable,
  },
  data() {
    return {
      options: [],
      spinning: false,
      selectclassify: [],
      columns,
      dataSource: [],
      pagination: {
        current: 1,
        pageSize: 10,
        total: 0,
        showTotal: (total) => `共 ${total} 条数据`,
      },
    };
  },
  computed: {
    ...mapGetters("organization", [
      "selectOrg",
      "orgTree",
      "orgList",
      "deptList",
      "filterOrgTree",
    ]),
    ...mapGetters("assetclassify", ["classifylist"]),
    ...mapGetters("vendor", ["vendorlist"]),
    ...mapState("setting", ["pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
  },
  mounted() {
    if (!this.classifylist.length) {
      this.getAllClassifylist().then(() => {
        this.getData();
      });
    } else {
      this.getData();
    }
  },
  methods: {
    ...mapActions("assetclassify", ["getAllClassifylist"]),
    getData() {
      this.spinning = true;
      childcatlist({
        pagination: {
          pageSize: this.pagination.pageSize,
          sortBy: "",
          page: this.pagination.current,
        },
        gsortid: this.selectclassify,
        statistics: true,
      })
        .then((res) => {
          this.spinning = false;
          if (res) {
            if (res.errcode === 0) {
              const { list, page, pageSize, total } = res.data ?? {};
              if (
                Array.isArray(list) &&
                list.length === 0 &&
                page > 1 &&
                total > 0
              ) {
                // 当请求的当前页数据为0 && 当前页不是第一页 && 总数不为0
                this.pagination.current = page - 1;
                this.pagination.pageSize = pageSize;
                this.getData();
              } else {
                this.dataSource = list.map((item) => {
                  return {
                    ...item,
                    gSortName: item.gsort ? item.gsort.name : "--",
                  };
                });
                this.pagination.current = page;
                this.pagination.pageSize = pageSize;
                this.pagination.total = total;
              }
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
    onPageChange(page, pageSize) {
      this.pagination.current = page;
      this.pagination.pageSize = pageSize;
      this.getData();
    },
    search() {
      this.pagination.current = 1;
      this.getData();
    },
    reset() {
      this.selectclassify = [];
      this.pagination.current = 1;
      this.getData();
    },
    filterOption(input, option) {
      return (
        option.componentOptions.children[0].text
          .toLowerCase()
          .indexOf(input.toLowerCase()) >= 0
      );
    },
  },
};
</script>

<style lang="less" scoped>
.labelRight {
  text-align: right;
  padding-right: 16px;
  white-space: nowrap;
}
.queryRow {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>