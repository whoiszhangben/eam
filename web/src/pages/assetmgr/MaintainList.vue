<template>
  <a-card :style="{ minHeight }">
    <a-spin :spinning="spinning">
      <div>
        <div v-if="goodsInfo.id">
          <a-row style="color: #333333; font-size: 14px; font-weight: 700">
            <a-col :span="24">
              {{ goodsInfo.name }}
            </a-col>
          </a-row>
          <a-divider />
          <div class="repairBtn">
            <a-button @click="addNew" type="primary" style="margin-right: 10px"
              >新增维修</a-button
            >
            <a-button @click="exportExcel1">导出excel</a-button>
          </div>
        </div>
        <div v-else>
          <a-row class="queryRowWrap">
            <a-col :span="5">
              <a-row class="queryRow">
                <a-col :span="6" class="labelRight">基地</a-col>
                <a-col :span="18">
                  <a-tree-select
                    v-model="selectOrgIds"
                    show-search
                    style="width: 100%"
                    :dropdown-style="{
                      maxHeight: '400px',
                      overflow: 'auto',
                    }"
                    tree-checkable
                    :maxTagPlaceholder="
                      () => {
                        return '... +' + (this.selectOrgIds.length - 1);
                      }
                    "
                    :showArrow="true"
                    placeholder="请选择"
                    :treeData="filterOrgTree"
                    :maxTagCount="1"
                    allow-clear
                    tree-default-expand-all
                    treeNodeFilterProp="title"
                    :replaceFields="{
                      title: 'name',
                      key: 'id',
                      value: 'id',
                    }"
                  >
                    <a-icon slot="suffixIcon" type="down" />
                  </a-tree-select>
                </a-col>
              </a-row>
            </a-col>
            <a-col :span="5">
              <a-row class="queryRow">
                <a-col :span="6" class="labelRight">部门</a-col>
                <a-col :span="18">
                  <a-select
                    v-model="selectDeptcodes"
                    show-search
                    optionFilterProp="children"
                    mode="multiple"
                    :showArrow="true"
                    placeholder="请选择"
                    style="width: 100%"
                    :allowClear="true"
                    :maxTagCount="1"
                    :maxTagTextLength="8"
                    :maxTagPlaceholder="
                      () => {
                        return '... +' + (this.selectDeptcodes.length - 1);
                      }
                    "
                  >
                    <a-icon slot="suffixIcon" type="down" />
                    <a-select-option v-for="dept in deptList" :key="dept.id">{{
                      dept.name
                    }}</a-select-option>
                  </a-select>
                </a-col>
              </a-row>
            </a-col>
            <a-col :span="5">
              <a-row class="queryRow">
                <a-col :span="6" class="labelRight">关键字</a-col>
                <a-col :span="18">
                  <a-input
                    placeholder="名称/位置/使用人/规格型号搜索"
                    v-model="searchText"
                  ></a-input>
                </a-col>
              </a-row>
            </a-col>
            <a-col :span="9">
              <a-button type="primary" @click="search" style="margin-left: 20px"
                >查询</a-button
              >
              <a-button @click="reset" style="margin-left: 20px">重置</a-button>
            </a-col>
          </a-row>
          <a-divider />
          <div class="repairBtn">
            <a-button @click="exportExcel2" type="primary" ghost
              >导出excel</a-button
            >
          </div>
        </div>
        <div v-if="goodsInfo.id">
          <standard-table
            :columns="columns"
            :dataSource="dataSource"
            :pagination="{ ...pagination, onChange: onPageChange }"
          >
            <div slot="index" slot-scope="{ text, record, index }">
              {{ index + 1 }}
            </div>
            <div slot="organizationId" slot-scope="{ text }">
              {{ getOrgName(text) }}
            </div>
            <div slot="ctime" slot-scope="{ text }">
              {{ momentFormat(text) }}
            </div>
          </standard-table>
          <div class="lossTips" v-if="dataSource.length">
            共计花费了 <span>{{ lossAmount.toFixed(2) }}</span> 元
          </div>
        </div>
        <div class="assetWrap" v-else>
          <div class="orgTree" v-resize.east>
            <a-tree
              :tree-data="orgTree"
              :selectedKeys.sync="selectedKeys"
              :expandedKeys.sync="expandedKeys"
              :auto-expand-parent="autoExpandParent"
              default-expand-all
              show-icon
              @select="onSelect"
              :replaceFields="{ title: 'name', key: 'id', value: 'id' }"
            >
            </a-tree>
          </div>
          <div class="assets">
            <standard-table
              :columns="columns2"
              :dataSource="dataSource"
              :pagination="{ ...pagination, onChange: onPageChange }"
            >
              <div slot="index" slot-scope="{ text, record, index }">
                {{ index + 1 }}
              </div>
              <div slot="ctime" slot-scope="{ text }">
                {{ momentFormat(text) }}
              </div>
            </standard-table>
          </div>
        </div>
      </div>
    </a-spin>
    <record-form
      ref="recordForm"
      :visible="visible"
      :goodsInfo="goodsInfo"
      @cancel="handleCancel"
      @create="handleCreate"
    ></record-form>
  </a-card>
</template>
  
    <script>
const RecordForm = {
  name: "RecordForm",
  data() {
    return {
      title: "",
    };
  },
  props: ["visible", "goodsInfo"],
  beforeCreate() {
    this.form = this.$form.createForm(this, { name: "" });
  },
  mounted() {
    console.log("执行mounted");
  },
  methods: {
    initData() {},
  },
  watch: {
    visible(nVal) {
      if (nVal) {
        this.title = "新增维修记录";
      } else {
        this.form.resetFields();
      }
    },
  },
  template: `
        <a-modal
          :visible="visible"
          :title='title'
          @cancel="() => { $emit('cancel') }"
          @ok="() => { $emit('create') }"
        >
          <a-form layout='vertical' :form="form" class="userForm">
            <a-form-item label='资产名称' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
              <a-input placeholder='请输入账号' :disabled="true"
                v-decorator="[
                  'goodsId', {
                    initialValue: goodsInfo.name
                  }
                ]"
              />
            </a-form-item>
            <a-form-item label='维修价格' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
              <a-input type="number" v-decorator="['price']" />
            </a-form-item>
            <a-form-item label='维修描述' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
              <a-input
                type='textarea'
                rows="5"
                v-decorator="['description']"
              />
            </a-form-item>
          </a-form>
        </a-modal>
      `,
};
import StandardTable from "@/components/table/StandardTable";
import { repairlist, repairrecordadd, repairexport } from "@/services/goods";
import resize from "@/directives/resize";
import moment from "moment";
import { mapState, mapGetters, mapActions } from "vuex";
const columns = [
  {
    title: "序号",
    dataIndex: "id",
    scopedSlots: { customRender: "index" },
  },
  {
    title: "使用部门",
    dataIndex: "organizationId",
    scopedSlots: { customRender: "organizationId" },
  },
  {
    title: "维修金额",
    dataIndex: "price",
  },
  {
    title: "维修时间",
    dataIndex: "ctime",
    scopedSlots: { customRender: "ctime" },
  },
  {
    title: "描述",
    dataIndex: "description",
  },
];
const columns2 = [
  {
    title: "序号",
    dataIndex: "id",
    scopedSlots: { customRender: "index" },
  },
  {
    title: "资产名称",
    dataIndex: "Gname",
  },
  {
    title: "资产类别",
    dataIndex: "Gsname",
  },
  {
    title: "规格型号",
    dataIndex: "Gmodel",
  },
  {
    title: "使用部门",
    dataIndex: "Oname",
  },
  {
    title: "维修金额",
    dataIndex: "price",
  },
  {
    title: "维修时间",
    dataIndex: "ctime",
    scopedSlots: { customRender: "ctime" },
  },
  {
    title: "备注",
    dataIndex: "description",
  },
];

export default {
  name: "MaintainList",
  components: {
    StandardTable,
    RecordForm,
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
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
  directives: {
    resize,
  },
  data() {
    return {
      advanced: true,
      columns,
      columns2,
      dataSource: [],
      visible: false,
      goodsInfo: {
        id: 0,
        name: "",
      },
      spinning: true,
      pagination: {
        current: 1,
        pageSize: 10,
        sortBy: "",
        order: 0,
        total: 0,
        showTotal: (total) => `共 ${total} 条数据`,
      },
      searchType: 0, // 0代表按关键字搜索， 1代表按机构id搜索
      selectOrgId: 0, // 选中的机构Id
      searchText: "",
      selectDeptcodes: [],
      selectOrgIds: [],
      selectedKeys: [],
      expandedKeys: [],
      autoExpandParent: true,
      lossAmount: 0,
    };
  },
  mounted() {
    // 如果是刷新页面进来的话， 需要重新获取基础数据后再load列表数据
    if (!this.orgTree.length) {
      this.loadBaseData().then(() => {
        console.log("this.orgTree", this.orgTree, this.deptList);
        this.expandedKeys = [1, 3];
        this.getData();
      });
    } else {
      this.expandedKeys = [1, 3];
      this.getData();
    }
  },
  methods: {
    ...mapActions("organization", ["getOrganizations"]),
    ...mapActions("assetclassify", ["getAllClassifylist"]),
    ...mapActions("vendor", ["getAllVendors"]),
    getData() {
      let goodsId = Number(this.$route.params.id);
      if (Number.isNaN(goodsId)) {
        this.goodsInfo.id = 0;
        this.getDataByChaos();
      } else {
        this.goodsInfo.id = goodsId;
        this.goodsInfo.name = this.$route.params.name;
        repairlist({
          pagination: {
            pageSize: this.pagination.pageSize,
            sortBy: this.pagination.sortBy,
            order: this.pagination.order,
            page: this.pagination.current,
          },
          keyword: "",
          deptCode: [],
          organizationId: [],
          goodsId: [goodsId],
        })
          .then((res) => {
            if (res.errcode === 0) {
              console.log("hello--------------", res);
              let sumAmount = 0;
              const list = res.data ? res.data.list : [];
              list.sort((a, b) => {
                let atime = new Date(a.ctime).getTime();
                let btime = new Date(b.ctime).getTime();
                if (atime > btime) {
                  return -1;
                } else if (atime < btime) {
                  return 1;
                } else {
                  return 0;
                }
              });
              this.dataSource = list;
              list.forEach((item) => {
                sumAmount += item.price ? Number(item.price) : 0;
              });
              this.lossAmount = sumAmount;
            } else {
              this.$message.error(res.errmsg);
            }
            this.spinning = false;
          })
          .catch((err) => {
            this.$message.error(err.message);
            this.spinning = false;
          });
      }
    },
    onPageChange(page, pageSize) {
      this.pagination.current = page;
      this.pagination.pageSize = pageSize;
      this.getData();
    },
    deleteRecord(key) {
      console.log(key);
    },
    toggleAdvanced() {
      this.advanced = !this.advanced;
    },
    remove() {},
    addNew() {
      this.visible = true;
    },
    handleCancel() {
      this.visible = false;
    },
    handleCreate() {
      const form = this.$refs.recordForm.form;
      form.validateFields((err, values) => {
        if (err) {
          return;
        }
        console.log("Received values of form: ", values);
        repairrecordadd({
          ...values,
          goodsId: this.goodsInfo.id,
          price: Number(values.price),
        })
          .then((res) => {
            if (res) {
              if (res.errcode === 0) {
                form.resetFields();
                this.getData();
                this.visible = false;
              } else {
                this.$message.error(res.errmsg);
              }
            } else {
              this.$message.error("服务异常， 请联系管理员");
            }
          })
          .catch((err) => {
            this.$message.error(err.message);
          });
      });
    },
    momentFormat(date, type = "YYYY-MM-DD HH:mm:ss") {
      return moment(date).format(type);
    },
    search() {
      this.pagination.current = 1;
      this.getDataByChaos();
    },
    reset() {
      this.selectOrgIds = [];
      this.selectDeptcodes = [];
      this.searchText = "";
      this.selectOrgId = 0;
      this.pagination.currU;
      this.pagination.current = 1;
      this.getData();
    },
    onSelect(selectedKeys) {
      this.searchType = 1;
      this.selectedKeys = selectedKeys;
      this.pagination.current = 1;
      if (Array.isArray(selectedKeys) && selectedKeys.length > 0) {
        this.selectOrgId = selectedKeys[0];
        this.getDataByDeptId(selectedKeys[0]);
      }
    },
    getDataByDeptId(deptId) {
      this.spinning = true;
      repairlist({
        pagination: {
          pageSize: this.pagination.pageSize,
          sortBy: this.pagination.sortBy,
          order: this.pagination.order,
          page: this.pagination.current,
        },
        organizationId: [deptId],
      })
        .then((res) => {
          if (res.errcode === 0) {
            const { list, page, pageSize, total } = res.data ?? {};
            this.dataSource = list;
            this.pagination.current = page;
            this.pagination.pageSize = pageSize;
            this.pagination.total = total;
          } else {
            this.$message.error(res.errmsg);
          }
          this.spinning = false;
        })
        .catch((err) => {
          this.spinning = false;
          this.$message.error(err.message);
        });
    },
    getDataByChaos() {
      this.spinning = true;
      this.selectedKeys = null;
      this.searchType = 0;
      repairlist({
        pagination: {
          pageSize: this.pagination.pageSize,
          sortBy: this.pagination.sortBy,
          order: this.pagination.order,
          page: this.pagination.current,
        },
        keyword: this.searchText,
        deptCode: this.selectDeptcodes,
        organizationId: this.selectOrgIds,
      })
        .then((res) => {
          if (res.errcode === 0) {
            const { list, page, pageSize, total } = res.data ?? {};
            this.dataSource = list;
            this.pagination.current = page;
            this.pagination.pageSize = pageSize;
            this.pagination.total = total;
          } else {
            this.$message.error(res.errmsg);
          }
          this.spinning = false;
        })
        .catch((err) => {
          this.spinning = false;
          this.$message.error(err.message);
        });
    },
    loadBaseData() {
      // 缓存一些基础数据
      return Promise.all([
        this.getOrganizations(),
        this.getAllClassifylist(),
        this.getAllVendors(),
      ]);
    },
    ArrayToTree(arr, parent = null) {
      if (!Array.isArray(arr) || !arr.length) return [];
      let newArr = [];
      arr.forEach((item) => {
        // 判断 当前item.parent 和 传入的parent 是否相等，相等就push 进去
        if (item.parent == parent) {
          newArr.push({
            ...item,
            children: this.ArrayToTree(arr, item.id),
          });
        }
      });
      return newArr;
    },
    ArrayToTree2(arr, parent = null) {
      if (!Array.isArray(arr) || !arr.length) return [];
      let newArr = [];
      arr.forEach((item) => {
        // 判断 当前item.parent 和 传入的parent 是否相等，相等就push 进去
        if (item.parent == parent && !item.isdept) {
          newArr.push({
            ...item,
            children: this.ArrayToTree2(arr, item.id),
          });
        }
      });
      return newArr;
    },
    exportExcel1() {
      repairexport({
        pagination: {
          pageSize: 10000,
          sortBy: this.pagination.sortBy,
          order: this.pagination.order,
          page: this.pagination.current,
        },
        keyword: this.searchText,
        deptCode: this.selectDeptcodes,
        organizationId: this.selectOrgIds,
        goodsid: [this.goodsInfo.id],
      })
        .then((res) => {
          if (res) {
            const file = new Blob([res], {
              type: "application/vnd.ms-excel",
            });
            const url = URL.createObjectURL(file);
            const a = document.createElement("a");
            a.href = url;
            a.click();
          } else {
            this.$message.error("服务异常， 请联系管理员");
          }
        })
        .catch((err) => {
          this.$message.error(err.message);
        });
    },
    exportExcel2() {
      if (this.searchType === 0) {
        repairexport({
          pagination: {
            pageSize: 10000,
            sortBy: this.pagination.sortBy,
            order: this.pagination.order,
            page: this.pagination.current,
          },
          keyword: this.searchText,
          deptCode: this.selectDeptcodes,
          organizationId: this.selectOrgIds,
        })
          .then((res) => {
            if (res) {
              const file = new Blob([res], {
                type: "application/vnd.ms-excel",
              });
              const url = URL.createObjectURL(file);
              const a = document.createElement("a");
              a.href = url;
              a.click();
            } else {
              this.$message.error("服务异常， 请联系管理员");
            }
          })
          .catch((err) => {
            this.$message.error(err.message);
          });
      } else {
        repairexport({
          pagination: {
            pageSize: 10000,
            sortBy: this.pagination.sortBy,
            order: this.pagination.order,
            page: this.pagination.current,
          },
          organizationId: [this.selectOrgId],
        })
          .then((res) => {
            if (res) {
              const file = new Blob([res], {
                type: "application/vnd.ms-excel",
              });
              const url = URL.createObjectURL(file);
              const a = document.createElement("a");
              a.href = url;
              a.click();
            } else {
              this.$message.error("服务异常， 请联系管理员");
            }
          })
          .catch((err) => {
            this.spinning = false;
            this.$message.error(err.message);
          });
      }
    },
    getOrgName(orgId) {
      let current = this.orgList.find((item) => item.id === Number(orgId));
      if (current) {
        return current.name;
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
.labelRight {
  text-align: right;
  padding-right: 16px;
  white-space: nowrap;
}
.queryRowWrap {
  margin-bottom: 20px;
}
.queryRow {
  display: flex;
  align-items: center;
  justify-content: center;
}
/deep/ .ant-divider,
.ant-divider-vertical {
  top: 0;
}
.assetWrap {
  display: flex;
  flex-flow: row;
}
.assets {
  flex: 1;
}
.orgTree {
  width: 228px;
  border: 1px solid #f0f0f0;
  margin-right: 10px;
}
.lossTips {
  color: #333333;
}
.lossTips > span {
  color: #1890ff;
}
.repairBtn {
  margin-bottom: 20px;
}
</style>
  