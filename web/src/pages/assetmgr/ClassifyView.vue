<template>
  <a-card :style="{ minHeight }">
    <a-spin :spinning="spinning">
      <div>
        <a-row style="color: #333333; font-weight: 700">
          <a-col :span="24">
            {{ currentSubClassify ? currentSubClassify.name : "--" }}
          </a-col>
        </a-row>
        <a-divider></a-divider>
        <a-row style="margin-bottom: 15px">
          <a-col :span="4" style="margin-right: 15px">
            <a-row class="queryRow">
              <a-col :span="7" class="labelRight">资产状态</a-col>
              <a-col :span="17">
                <a-select
                  v-model="selectStates"
                  show-search
                  option-filter-prop="children"
                  :filter-option="filterOption"
                  mode="multiple"
                  placeholder="请选择"
                  style="width: 100%"
                  :allowClear="true"
                  :showArrow="true"
                  :maxTagCount="1"
                  :maxTagTextLength="8"
                  :maxTagPlaceholder="
                    () => {
                      return '... +' + (this.selectStates.length - 1);
                    }
                  "
                >
                  <a-icon slot="suffixIcon" type="down" />
                  <a-select-option
                    v-for="state in assetState"
                    :key="state.id"
                    >{{ state.name }}</a-select-option
                  >
                </a-select>
              </a-col>
            </a-row>
          </a-col>
          <a-col :span="4">
            <a-input-search
              placeholder="搜索关键字"
              v-model="searchText"
            ></a-input-search>
          </a-col>
          <a-col :span="14">
            <a-button type="primary" @click="search" style="margin-left: 20px"
              >查询</a-button
            >
            <a-button @click="reset" style="margin-left: 20px">重置</a-button>
          </a-col>
        </a-row>
        <a-row class="btnList">
          <a-button type="primary" @click="addAsset" class="assetbtn"
            >新增</a-button
          >
          <a-button @click="collectAsset" class="assetbtn" type="primary" ghost
            >领用</a-button
          >
          <a-button @click="transferAsset" class="assetbtn" type="primary" ghost
            >转让</a-button
          >
          <a-button @click="backAsset" class="assetbtn" type="primary" ghost
            >归还</a-button
          >
          <a-button @click="loseAsset" class="assetbtn" type="primary" ghost
            >丢失</a-button
          >
          <a-button @click="discardAsset" class="assetbtn" type="primary" ghost
            >报废</a-button
          >
          <a-button @click="choosePrint" class="assetbtn" type="primary" ghost
            >打印</a-button
          >
          <a-button @click="batchDel" class="assetbtn" type="primary" ghost
            >删除</a-button
          >
          <a-button @click="downTemplate" type="primary" ghost class="assetbtn"
            >下载导入模板</a-button
          >
          <a-upload :showUploadList="false" :customRequest="customRequest"
            ><a-button class="assetbtn" type="primary" ghost
              >批量导入</a-button
            ></a-upload
          >
          <a-button @click="exportData" class="assetbtn" type="primary" ghost
            >导出Excel</a-button
          >
        </a-row>

        <standard-table
          :columns="columns"
          :dataSource="dataSource"
          :selectedRows.sync="selectedRows"
          :pagination="{ ...pagination, onChange: onPageChange }"
        >
          <div slot="id" slot-scope="{ text }">
            {{ formatId(text) }}
          </div>
          <div slot="state" slot-scope="{ text }">
            {{ getAssetState(text) }}
          </div>
          <div slot="buyTime" slot-scope="{ text }">
            {{ text ? moment(text).format("YYYY-MM-DD") : "--" }}
          </div>
          <div slot="action" slot-scope="{ text, record }">
            <a style="margin-right: 8px" @click="modifyAsset(record)">修改</a>
            <a
              style="margin-right: 8px; color: #ff1818"
              @click="deleteAsset(record)"
              >删除</a
            >
            <router-link
              :to="`/assetmgr/assetlist/flow/${record.id}/${encodeURIComponent(
                record.name
              )}`"
              style="margin-right: 8px"
              >流水</router-link
            >
            <router-link
              :to="`/assetmgr/assetlist/maintainlist/${
                record.id
              }/${encodeURIComponent(record.name)}`"
              style="margin-right: 8px"
              >维修</router-link
            >
            <a style="margin-right: 8px" @click="viewAsset(record)">查看</a>
          </div>
        </standard-table>
      </div>
    </a-spin>
    <goods-form
      ref="goodsForm"
      :visible="visible"
      :modalData="modalData"
      :opType="opType"
      :searchType="searchType"
      :selectOrgId="selectOrgId"
      :currentSubClassify="currentSubClassify"
      @cancel="handleCancel"
      @create="handleCreate"
    ></goods-form>
    <transfer-modal
      ref="batchForm"
      :opType="batchOpType"
      :batchModalVisible="batchModalVisible"
      @cancel="handleBatchCancel"
      @create="handleBatch"
    ></transfer-modal>
    <print-modal
      :printModalVisible="printModalVisible"
      @close="printModalVisible = false"
      @printAsset="printAsset"
    ></print-modal>
  </a-card>
</template>

<script>
import { mapState, mapGetters, mapActions } from "vuex";
import { enums } from "@/utils/enum";
import {
  goodslist,
  goodsadd,
  goodsedit,
  goodsdel,
  print,
  printAll,
  importGoodsList,
  exportGoods,
  exportTemplate,
} from "@/services/goods";
import moment from "moment";
import { getAssetState } from "@/utils/util";
import PrintModal from "@/components/dialog/printModal";
import StandardTable from "@/components/table/StandardTable";

const GoodsForm = {
  data() {
    return {
      title: "",
      dataForm: {
        name: "",
        account: "",
        role: 0,
        description: "",
      },
    };
  },
  props: [
    "visible",
    "opType",
    "modalData",
    "searchType",
    "selectOrgId",
    "currentSubClassify",
  ],
  beforeCreate() {
    this.form = this.$form.createForm(this, { name: "" });
  },
  computed: {
    ...mapGetters("assetclassify", ["classifylist"]),
    ...mapGetters("vendor", ["vendorlist"]),
    ...mapGetters("organization", ["orgTree", "orglist"]),
    classifyOptions() {
      let resArr = [];
      this.classifylist.forEach((item) => {
        if (Array.isArray(item.childGsort) && item.childGsort.length) {
          let children = [];
          item.childGsort.forEach((sub) => {
            children.push({
              label: sub.name,
              value: sub.id,
            });
          });
          resArr.push({
            label: item.name,
            value: item.id,
            children,
          });
        }
      });
      return resArr;
    },
  },
  methods: {
    moment,
    onClassifyChange(value) {
      console.log("当前选中的value:", value);
    },
    displayRender({ labels }) {
      return labels[labels.length - 1];
    },
  },
  watch: {
    visible(nVal) {
      if (nVal) {
        console.log(this.currentSubClassify, "------------------------");
        switch (this.opType) {
          case 0:
            this.title = "新增资产";
            break;
          case 1:
            this.title = "编辑资产";
            break;
          default:
            this.title = "资产详情";
            break;
        }
        console.log("当前传入的modalData:", this.modalData);
        this.$nextTick(() => {
          setTimeout(() => {
            if (this.modalData) {
              this.form.setFieldsValue({
                name: this.modalData.name,
                gSortId: this.modalData.gSortId,
                childGsortid: [
                  this.modalData.gSortId,
                  this.modalData.childGsortid,
                ],
                model: this.modalData.model,
                buyTime: this.modalData.buyTime
                  ? moment(this.modalData.buyTime, "YYYY-MM-DD")
                  : null,
                price: this.modalData.price,
                orgId: this.modalData.orgId,
                savelocation: this.modalData.savelocation,
                custodian: this.modalData.custodian,
                amount: this.modalData.amount,
                unit: this.modalData.unit,
                vendorId: this.modalData.vendorId,
                description: this.modalData.description,
              });
            } else {
              this.form.setFieldsValue({
                childGsortid: [
                  this.currentSubClassify.gsortid,
                  this.currentSubClassify.id,
                ],
              });
            }
          }, 1);
        });
      } else {
        this.form.resetFields();
      }
    },
  },
  template: `
        <a-modal
          :visible="visible"
          :opType="opType"
          :title="title"
          width="820px"
          @cancel="() => { $emit('cancel') }"
          @ok="() => { $emit('create') }"
          class="goodsModal"
          :cancelText = "opType === 2 ? '关闭' : '取消'"
          :ok-button-props="{ style: opType === 2 ? { display: 'none' } : null }"
        >
          <a-form layout='vertical' :form="form" class="goodsForm">
            <a-row>
              <a-col :span="10" :offset="2">
                <a-form-item label='资产名称' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-input placeholder='请输入资产名称' :disabled="opType===2"
                    v-decorator="[
                      'name',
                      {
                        rules: [{ required: true, message: '请输入资产名称' }],
                      }
                    ]"
                  />
                </a-form-item>
              </a-col>
              <a-col :span="10">
                <a-form-item label='资产子类别' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-cascader
                  v-decorator="[
                    'childGsortid',
                    {
                      rules: [{ required: true, message: '请选择资产类别' }],
                    }
                  ]"
                    :options="classifyOptions"
                    :display-render="displayRender"
                    placeholder="请选择"
                    @change="onClassifyChange" :disabled="opType===2">
                  </a-cascader>
                </a-form-item>
              </a-col>
            </a-row>
            
            <a-row>
              <a-col :span="10" :offset="2">
                <a-form-item label='购买价格' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-input :disabled="opType===2" type="number" v-decorator="['price']" />
                </a-form-item>
              </a-col>
              <a-col :span="10">
                <a-form-item label='使用部门' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-tree-select :disabled="opType===2" v-decorator="[
                    'orgId', {
                      rules: [{ required: true, message: '请选择使用部门' }],
                    },
                    {
                      initialValue: searchType === 1 ? selectOrgId : null
                    }
                  ]" placeholder="请选择"
                    show-search
                    style="width: 100%"
                    :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
                    :treeData="orgTree"
                    allow-clear
                    tree-default-expand-all
                    treeNodeFilterProp="title"
                    :replaceFields="{title: 'name', key: 'id', value: 'id'}"
                  >
                  </a-tree-select>
                </a-form-item>
              </a-col>
            </a-row>
            <a-row>
              <a-col :span="10" :offset="2">
                <a-form-item label='购买数量' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-input :disabled="opType===2" type="number"
                    v-decorator="['amount', { initialValue: 1 }]" 
                  />
                </a-form-item>
              </a-col>
              <a-col :span="10">
                <a-form-item label='使用人' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-input :disabled="opType===2"
                    v-decorator="['custodian']"
                  />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row>
              <a-col :span="10" :offset="2">
                <a-form-item label='购买日期' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-date-picker :disabled="opType===2" v-decorator="['buyTime', { initialValue: moment()}]" style="width: 100%" />
                </a-form-item>
              </a-col>
              <a-col :span="10">
                <a-form-item label='单位' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-input :disabled="opType===2"
                    v-decorator="['unit', { initialValue: '个' } ]"
                  />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row>
              <a-col :span="10" :offset="2">
                <a-form-item label='供应商' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-select v-decorator="[
                    'vendorId'
                  ]" placeholder="请选择" :disabled="opType===2">
                    <a-select-option v-for="item in vendorlist" :key="item.id">{{ item.name }}</a-select-option>
                  </a-select>
                </a-form-item>
              </a-col>
              <a-col :span="10">
                <a-form-item label='保修期限(月)' :labelCol="{span: 6}" :wrapperCol="{span: 16}">
                  <a-input type="number" :disabled="opType===2"
                    v-decorator="['warrantyPeriod']"
                  />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row>
              <a-col :span="20" :offset="2">
                <a-form-item label='储存位置' :labelCol="{span: 3}" :wrapperCol="{span: 20}">
                  <a-input :disabled="opType===2"
                  type='textarea'
                  rows="1"
                    v-decorator="['savelocation']"
                  />
                </a-form-item>
              </a-col>
              
            </a-row>
            <a-row>
              <a-col :span="20" :offset="2">
                <a-form-item label='规格/型号' :labelCol="{span: 3}" :wrapperCol="{span: 20}">
                  <a-input :disabled="opType===2"
                  type='textarea'
                  rows="1"
                    v-decorator="['model']"
                  />
                </a-form-item>
              </a-col>
              
            </a-row>
            <a-row>
              <a-col :span="20" :offset="2">
                <a-form-item label='备注' :labelCol="{span: 3}" :wrapperCol="{span: 20}">
                  <a-input :disabled="opType===2"
                    type='textarea'
                    rows="5"
                    v-decorator="['description']"
                  />
                </a-form-item>
              </a-col>
            </a-row>
          </a-form>
        </a-modal>
      `,
};
const TransferModal = {
  data() {
    return {};
  },
  props: ["batchModalVisible", "opType"],
  computed: {
    ...mapGetters("organization", ["orgTree"]),
  },
  beforeCreate() {
    this.form = this.$form.createForm(this, { name: "" });
  },
  watch: {
    batchModalVisible(nVal) {
      if (!nVal) {
        this.form.resetFields();
      }
    },
  },
  template: `
      <a-modal
        :visible="batchModalVisible"
        :title="opType ? '资产领用' : '资产转让'"
        @cancel="() => { $emit('cancel') }"
        @ok="() => { $emit('create') }"
      >
        <a-form layout='vertical' :form="form" class="batchForm">
          <a-form-item :label="opType ? '领用机构' : '转入机构'" :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-tree-select v-decorator="[
                  'orgId', 
                  {
                  rules: [{ required: true, message: opType ? '请选择领用的机构' : '请选择被转入的机构' }],
                }
                ]" placeholder="请选择"
                  show-search
                  style="width: 100%"
                  :dropdown-style="{ maxHeight: '400px', overflow: 'auto' }"
                  :treeData="orgTree"
                  allow-clear
                  tree-default-expand-all
                  treeNodeFilterProp="title"
                  :replaceFields="{title: 'name', key: 'id', value: 'id'}"
                >
                </a-tree-select>
          </a-form-item>
          <a-form-item :label="opType ? '领用人' : '被转让人'" :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-input :placeholder="opType ? '请输入领用人的名字' : '请输入被转让人的名字'"
              v-decorator="[
                'custodian',
                {
                  rules: [{ required: true, message: opType ? '请输入领用人的名字' : '请输入被转让人的名字' }],
                }
              ]"
            />
          </a-form-item>
          <a-form-item label="位置" :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-input placeholder="请输入资产位置信息"
              v-decorator="[
                'savelocation'
              ]"
            />
          </a-form-item>
          <a-form-item label='备注' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
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
const columns = [
  {
    title: "资产编号",
    dataIndex: "id",
    scopedSlots: { customRender: "id" },
  },
  {
    title: "资产名称",
    dataIndex: "name",
  },
  {
    title: "部门",
    dataIndex: "organizationName",
  },
  {
    title: "规格型号",
    dataIndex: "model",
  },
  {
    title: "供应商",
    dataIndex: "vendorName",
  },
  {
    title: "资产状态",
    dataIndex: "state",
    scopedSlots: { customRender: "state" },
  },
  {
    title: "购买日期",
    dataIndex: "buyTime",
    scopedSlots: { customRender: "buyTime" },
  },
  {
    title: "使用人",
    dataIndex: "custodian",
  },
  {
    title: "操作",
    scopedSlots: { customRender: "action" },
  },
];
const assetState = [
  {
    name: "闲置",
    id: 1,
  },
  {
    name: "领用",
    id: 2,
  },
  {
    name: "归还",
    id: 3,
  },
  {
    name: "遗失",
    id: 4,
  },
  {
    name: "转让",
    id: 5,
  },
  {
    name: "报废",
    id: 6,
  },
];
export default {
  name: "ClassifyView",
  components: { StandardTable, GoodsForm, TransferModal, PrintModal },
  data() {
    return {
      currentSubClassify: null,
      spinning: false,
      searchText: "",
      selectStates: [],
      pagination: {
        current: 1,
        pageSize: 10,
        sortBy: "",
        order: 0,
        total: 0,
      },
      assetState,
      opType: 0,
      visible: false,
      modalData: null,
      printModalVisible: false,
      selectDeptcodes: [],
      selectOrgIds: [],
      columns,
      dataSource: [],
      selectedRows: [],
      searchType: 0,
      selectOrgId: 0,
      batchOpType: 0, // 0为转让 1为领用
      isBatchOp: 1, // 0为单个操作 1为批量操作
      singleAsset: null, // 缓存转让或领用的资产信息
      batchModalVisible: false,
      collectVisible: false,
    };
  },
  mounted() {
    if (!this.orgTree.length) {
      this.loadBaseData().then(() => {
        this.getData();
      });
    } else {
      this.getData();
    }
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
    ...mapState("account", { currUser: "user" }),
    ...mapState("setting", ["pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
  },
  methods: {
    moment,
    ...mapActions("organization", ["getOrganizations"]),
    ...mapActions("assetclassify", ["getAllClassifylist"]),
    ...mapActions("vendor", ["getAllVendors"]),
    loadBaseData() {
      // 缓存一些基础数据
      return Promise.all([
        this.getOrganizations(),
        this.getAllClassifylist(),
        this.getAllVendors(),
      ]);
    },
    getData() {
      let subClassifyId = Number(this.$route.params.id);
      // 根据信息查找子分类节点
      this.currentSubClassify = this.searchTreeById(
        this.classifylist,
        subClassifyId
      );
      this.spinning = true;
      this.selectedKeys = null;
      this.searchType = 0;
      goodslist({
        pagination: {
          pageSize: this.pagination.pageSize,
          sortBy: this.pagination.sortBy,
          order: this.pagination.order,
          page: this.pagination.current,
        },
        keyword: this.searchText,
        deptCode: this.selectDeptcodes,
        organizationId: this.selectOrgIds,
        state: this.selectStates,
        id: [],
        childGsortid: [subClassifyId],
      })
        .then((res) => {
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
                  vendorName: item.vendor ? item.vendor.name : "--",
                  organizationName: item.organization
                    ? item.organization.name
                    : "--",
                };
              });
              this.pagination.current = page;
              this.pagination.pageSize = pageSize;
              this.pagination.total = total;
            }
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
    onPageChange(page, pageSize) {
      console.log("onPageChange trigger ?");
      this.pagination.current = page;
      this.pagination.pageSize = pageSize;
      if (this.searchType === 0) {
        this.getData();
      } else {
        this.getDataByDeptId(this.selectOrgId);
      }
    },
    search() {
      this.pagination.current = 1;
      this.getData();
    },
    reset() {
      this.selectOrgIds = [];
      this.selectDeptcodes = [];
      this.selectStates = [];
      this.selectclassify = [];
      this.searchText = "";
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
    addAsset() {
      this.opType = 0;
      this.visible = true;
      this.modalData = null;
    },
    deleteAsset(asset) {
      let self = this;
      this.$confirm({
        title: "删除资产",
        content: "您确定要删除当前资产吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          goodsdel({
            id: [asset.id],
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("删除成功");
                  if (self.searchType === 0) {
                    self.getData();
                  } else {
                    self.getDataByDeptId(self.selectOrgId);
                  }
                } else {
                  self.$message.error(res.errmsg);
                }
              } else {
                self.$message.error("服务异常， 请联系管理员");
              }
            })
            .catch((err) => {
              self.$message.error(err.message);
            });
        },
      });
    },
    modifyAsset(asset) {
      this.opType = 1;
      this.visible = true;
      this.modalData = asset;
    },
    viewAsset(asset) {
      this.opType = 2;
      this.visible = true;
      this.modalData = asset;
    },
    customRequest(data) {
      const formData = new FormData();
      formData.append("fcontent", data.file);
      importGoodsList(formData)
        .then((res) => {
          if (res.errcode === 0) {
            this.$message.info("导入成功");
            if (this.searchType === 0) {
              this.getData();
            } else {
              this.getDataByDeptId(this.selectOrgId);
            }
          } else {
            this.$message.error(res.errmsg);
          }
        })
        .catch((err) => {
          this.$message.error(err.message);
        });
    },
    exportData() {
      // exportGoods()
      let ids = this.selectedRows.map((item) => item.id);
      let self = this;
      if (!ids.length) {
        this.$confirm({
          title: "批量导出",
          content:
            "批量导出未选择意味着当前查询的数据全量导出，您确定全量导出吗？",
          okText: "确认",
          cancelText: "取消",
          onOk() {
            if (self.searchType === 0) {
              exportGoods({
                organizationId: self.selectOrgIds,
                deptCode: self.selectDeptcodes,
                keyword: self.searchText,
              })
                .then((res) => {
                  if (res) {
                    console.log(res);
                    const file = new Blob([res], {
                      type: "application/vnd.ms-excel",
                    });
                    const url = URL.createObjectURL(file);
                    const a = document.createElement("a");
                    a.href = url;
                    a.click();
                  } else {
                    self.$message.error("服务异常， 请联系管理员");
                  }
                })
                .catch((err) => {
                  self.$message.error(err.message);
                });
            } else {
              exportGoods({
                organizationId: [self.selectOrgId],
              })
                .then((res) => {
                  if (res) {
                    console.log(res);
                    const file = new Blob([res], {
                      type: "application/vnd.ms-excel",
                    });
                    const url = URL.createObjectURL(file);
                    const a = document.createElement("a");
                    a.href = url;
                    a.click();
                  } else {
                    self.$message.error("服务异常， 请联系管理员");
                  }
                })
                .catch((err) => {
                  self.$message.error(err.message);
                });
            }
          },
        });
      } else {
        this.$confirm({
          title: "批量导出",
          content: "您确定要批量导出选中的资产吗？",
          okText: "确认",
          cancelText: "取消",
          onOk() {
            exportGoods({
              ids,
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
                  self.$message.error("服务异常， 请联系管理员");
                }
              })
              .catch((err) => {
                self.$message.error(err.message);
              });
          },
        });
      }
    },
    // 打印资产
    printAsset(printId) {
      localStorage.setItem("printOption", printId);
      let ids = this.selectedRows.map((item) => item.id);
      let self = this;
      if (!ids.length) {
        this.$confirm({
          title: "条码打印",
          content:
            "未选中任何资产时，将打印全部资产条码，是否打印全部资产条码？",
          okText: "确认",
          cancelText: "取消",
          onOk() {
            if (self.searchType === 0) {
              printAll({
                orgId: self.selectOrgIds,
                deptcode: self.selectDeptcodes,
                keyword: self.searchText,
                print: printId,
              })
                .then((res) => {
                  if (res) {
                    if (res.errcode === 0) {
                      self.$message.info("打印成功");
                    } else {
                      self.$message.error(res.errmsg);
                    }
                  } else {
                    self.$message.error("服务异常， 请联系管理员");
                  }
                })
                .catch((err) => {
                  self.$message.error(err.message);
                });
            } else {
              printAll({
                orgId: [self.selectOrgId],
                print: printId,
              })
                .then((res) => {
                  if (res) {
                    if (res.errcode === 0) {
                      self.$message.info("打印成功");
                    } else {
                      self.$message.error(res.errmsg);
                    }
                  } else {
                    self.$message.error("服务异常， 请联系管理员");
                  }
                })
                .catch((err) => {
                  self.$message.error(err.message);
                });
            }
          },
        });
      } else {
        this.$confirm({
          title: "条码打印",
          content: "您确定要打印选中的资产吗？",
          okText: "确认",
          cancelText: "取消",
          onOk() {
            print({
              goodsId: ids,
              print: printId,
            })
              .then((res) => {
                if (res) {
                  if (res.errcode === 0) {
                    self.$message.info("打印成功");
                    self.selectedRows = [];
                  } else {
                    self.$message.error(res.errmsg);
                  }
                } else {
                  self.$message.error("服务异常， 请联系管理员");
                }
              })
              .catch((err) => {
                self.$message.error(err.message);
              });
          },
        });
      }
    },
    choosePrint() {
      this.printModalVisible = true;
    },
    // 领用资产
    collectAsset() {
      let ids = this.selectedRows.map((item) => item.id);
      if (!ids.length) {
        this.$message.info("请选择您要领用的资产");
        return;
      }
      let nums1 = this.selectedRows.filter(
        (x) =>
          x.state === enums.GoodsState.STATE_USED ||
          x.state === enums.GoodsState.STATE_CEDE
      );
      if (nums1.length) {
        if (nums1.length === this.selectedRows.length) {
          this.$message.error(`当前选择的资产处于已领用的状态,不能领用`);
        } else {
          this.$message.error(
            `当前选择的资产有${nums1.length}条处于已领用的状态,不能领用`
          );
        }
        return;
      }

      let nums2 = this.selectedRows.filter(
        (x) => x.state === enums.GoodsState.STATE_LOSE
      );
      if (nums2.length) {
        if (nums2.length === this.selectedRows.length) {
          this.$message.error(`当前选择的资产处于遗失的状态,不能领用`);
        } else {
          this.$message.error(
            `当前选择的资产有${nums2.length}条处于遗失的状态,不能领用`
          );
        }
        return;
      }
      this.batchModalVisible = true;
      this.batchOpType = 1;
    },
    // 转让资产
    transferAsset() {
      let ids = this.selectedRows.map((item) => item.id);
      if (!ids.length) {
        this.$message.info("请选择您要转让的资产");
        return;
      }
      let nums2 = this.selectedRows.filter(
        (x) => x.state !== enums.GoodsState.STATE_USED
      );
      if (nums2.length) {
        if (nums2.length === this.selectedRows.length) {
          this.$message.error(`当前选择的资产处于非领用的状态,不能转让`);
        } else {
          this.$message.error(
            `当前选择的资产有${nums2.length}条处于非领用的状态,不能转让`
          );
        }
        return;
      }
      this.batchModalVisible = true;
      this.batchOpType = 0;
    },
    // 归还资产
    backAsset() {
      let ids = this.selectedRows.map((item) => item.id);
      let params = ids.map((id) => {
        return {
          id,
          state: enums.GoodsState.STATE_BACK,
        };
      });
      if (!ids.length) {
        this.$message.info("请选择您要归还的资产");
        return;
      }
      let nums2 = this.selectedRows.filter(
        (x) =>
          x.state !==
          (enums.GoodsState.STATE_USED || enums.GoodsState.STATE_CEDE)
      );
      if (nums2.length) {
        if (nums2.length === this.selectedRows.length) {
          this.$message.error(`当前选择的资产处于非领用或转让的状态,不能归还`);
        } else {
          this.$message.error(
            `当前选择的资产有${nums2.length}条处于非领用或转让的状态,不能归还`
          );
        }

        return;
      }
      let self = this;
      this.$confirm({
        title: "归还资产",
        content: "您确定要归还当前所选的资产吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          goodsedit({
            goods: params,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("归还成功");
                  self.selectedRows = [];
                  if (self.searchType === 0) {
                    self.getData();
                  } else {
                    self.getDataByDeptId(self.selectOrgId);
                  }
                } else {
                  self.$message.error(res.errmsg);
                }
              } else {
                self.$message.error("服务异常， 请联系管理员");
              }
            })
            .catch((err) => {
              self.$message.error(err.message);
            });
        },
      });
    },
    // 报废资产
    discardAsset() {
      let ids = this.selectedRows.map((item) => item.id);
      let params = ids.map((id) => {
        return {
          id,
          state: enums.GoodsState.STATE_SCRAP,
        };
      });
      if (!ids.length) {
        this.$message.info("请选择您要报废的资产");
        return;
      }
      let self = this;
      this.$confirm({
        title: "报废资产",
        content: "您确定要报废当前所选的资产吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          goodsedit({
            goods: params,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("报废成功");
                  self.selectedRows = [];
                  if (self.searchType === 0) {
                    self.getData();
                  } else {
                    self.getDataByDeptId(self.selectOrgId);
                  }
                } else {
                  self.$message.error(res.errmsg);
                }
              } else {
                self.$message.error("服务异常， 请联系管理员");
              }
            })
            .catch((err) => {
              self.$message.error(err.message);
            });
        },
      });
    },
    // 丢失资产
    loseAsset() {
      let ids = this.selectedRows.map((item) => item.id);
      let params = ids.map((id) => {
        return {
          id,
          state: enums.GoodsState.STATE_LOSE,
        };
      });
      if (!ids.length) {
        this.$message.info("请选择您要丢失的资产");
        return;
      }
      let self = this;
      this.$confirm({
        title: "丢失资产",
        content: "您确定要丢失当前所选的资产吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          goodsedit({
            goods: params,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("丢失成功");
                  self.selectedRows = [];
                  if (self.searchType === 0) {
                    self.getData();
                  } else {
                    self.getDataByDeptId(self.selectOrgId);
                  }
                } else {
                  self.$message.error(res.errmsg);
                }
              } else {
                self.$message.error("服务异常， 请联系管理员");
              }
            })
            .catch((err) => {
              self.$message.error(err.message);
            });
        },
      });
    },
    getAssetState,
    getOrgName(orgId) {
      if (Array.isArray(this.orgList)) {
        let current = this.orgList.find((item) => item.id === Number(orgId));
        if (current) {
          return current.name;
        } else {
          return "--";
        }
      } else {
        return "--";
      }
    },
    handleCreate() {
      const form = this.$refs.goodsForm.form;
      form.validateFields((err, values) => {
        if (err) {
          return;
        }
        console.log("Received values of form: ", values);
        if (this.opType === 0) {
          goodsadd({
            goods: [
              {
                ...values,
                amount: Number(values.amount),
                price: Number(values.price),
                warrantyPeriod: Number(values.warrantyPeriod),
                buyTime: values.buyTime
                  ? moment(values.buyTime).format("YYYY-MM-DD HH:mm:ss")
                  : null,
                gSortId: values.childGsortid[0],
                childGsortid: values.childGsortid[1],
              },
            ],
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  form.resetFields();
                  this.$message.info("新增成功");
                  if (this.searchType === 0) {
                    this.getData();
                  } else {
                    this.getDataByDeptId(this.selectOrgId);
                  }
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
        } else if (this.opType === 1) {
          // 编辑
          goodsedit({
            goods: [
              {
                ...values,
                amount: Number(values.amount),
                price: Number(values.price),
                buyTime: values.buyTime
                  ? moment(values.buyTime).format("YYYY-MM-DD HH:mm:ss")
                  : null,
                gSortId: values.childGsortid[0],
                childGsortid: values.childGsortid[1],
                id: this.modalData.id,
              },
            ],
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  form.resetFields();
                  if (this.searchType === 0) {
                    this.getData();
                  } else {
                    this.getDataByDeptId(this.selectOrgId);
                  }
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
        } else if (this.opType === 2) {
          // todo 查看
        }
      });
    },
    handleCancel() {
      const form = this.$refs.goodsForm.form;
      form.resetFields();
      this.visible = false;
    },
    handleBatchCancel() {
      const form = this.$refs.batchForm.form;
      form.resetFields();
      this.batchModalVisible = false;
    },
    handleBatch() {
      const form = this.$refs.batchForm.form;
      form.validateFields((err, values) => {
        if (err) {
          return;
        }
        let params = null;
        if (this.isBatchOp) {
          params = this.selectedRows.map((item) => {
            return {
              ...values,
              id: item.id,
              state: this.batchOpType
                ? enums.GoodsState.STATE_USED
                : enums.GoodsState.STATE_CEDE,
            };
          });
        } else {
          params = [
            {
              ...values,
              id: this.singleAsset.id,
              state: this.batchOpType
                ? enums.GoodsState.STATE_USED
                : enums.GoodsState.STATE_CEDE,
            },
          ];
        }
        goodsedit({
          goods: params,
        })
          .then((res) => {
            if (res) {
              if (res.errcode === 0) {
                this.batchOpType
                  ? this.$message.info("领用成功")
                  : this.$message.info("转让成功");
                this.selectedRows = [];
                this.batchModalVisible = false;
                if (this.searchType === 0) {
                  this.getData();
                } else {
                  this.getDataByDeptId(this.selectOrgId);
                }
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
    batchDel() {
      let ids = this.selectedRows.map((item) => item.id);
      if (!ids.length) {
        this.$message.info("请选择您要删除的资产");
        return;
      }
      let self = this;
      this.$confirm({
        title: "删除资产",
        content: "您确定要删除当前所选的资产吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          goodsdel({
            id: ids,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("删除成功");
                  if (self.searchType === 0) {
                    self.getData();
                  } else {
                    self.getDataByDeptId(self.selectOrgId);
                  }
                } else {
                  self.$message.error(res.errmsg);
                }
              } else {
                self.$message.error("服务异常， 请联系管理员");
              }
            })
            .catch((err) => {
              self.$message.error(err.message);
            });
        },
      });
    },
    formatId(rawId) {
      return rawId.toString().padStart(5, "0");
    },
    // 只有两级 查找子分类Id
    searchTreeById(nodes, id) {
      for (let i = 0; i < nodes.length; i++) {
        let subNodes = nodes[i].childGsort;
        if (Array.isArray(subNodes) && subNodes.length > 0) {
          for (let j = 0; j < subNodes.length; j++) {
            if (subNodes[j].id === id) {
              return subNodes[j];
            }
          }
        }
      }
    },
    downTemplate() {
      exportTemplate()
        .then((res) => {
          if (res) {
            console.log(res);
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
.btnList {
  margin: 20px 0;
}
.assetbtn {
  margin-right: 10px;
}
.goodsModal /deep/ .ant-form-item label {
  top: 4px;
  white-space: nowrap;
}

/deep/ .ant-form-vertical .ant-form-item-label,
.ant-col-24.ant-form-item-label,
.ant-col-xl-24.ant-form-item-label {
  margin-right: 10px !important;
  text-align: right !important;
  line-height: 32px !important;
}
</style>