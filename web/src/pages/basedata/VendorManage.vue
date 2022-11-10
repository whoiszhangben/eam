<template>
  <a-card :style="{ minHeight }">
    <a-spin :spinning="spinning">
      <div>
        <a-row style="margin-bottom: 15px">
          <a-col :span="4">
            <a-input placeholder="搜索关键字" v-model="searchText"></a-input>
          </a-col>
          <a-col :span="14">
            <a-button type="primary" @click="search" style="margin-left: 20px"
              >查询</a-button
            >
            <a-button @click="reset" style="margin-left: 20px">重置</a-button>
          </a-col>
          <a-col :span="6" style="text-align: right">
            <a-button @click="addNew" type="primary"
              ><a-icon type="plus"></a-icon>新增供应商</a-button
            >
          </a-col>
        </a-row>
        <standard-table
          :columns="columns"
          :dataSource="dataSource"
          :pagination="{ ...pagination, onChange: onPageChange }"
        >
          <div slot="index" slot-scope="{ text, record, index }">
            {{ index + 1 }}
          </div>
          <div slot="action" slot-scope="{ text, record }">
            <a style="margin-right: 8px" @click="modifyVendor(record)">
              修改
            </a>
            <a @click="deleteVendor(record)" style="color: #ff1818">删除 </a>
          </div>
        </standard-table>
      </div>
    </a-spin>
    <vendor-form
      ref="vendorForm"
      :opType="opType"
      :visible="visible"
      :modalData="modalData"
      @cancel="handleCancel"
      @create="handleCreate"
    ></vendor-form>
  </a-card>
</template>
  
    <script>
const vendorForm = {
  data() {
    return {
      title: "",
    };
  },
  props: ["visible", "opType", "modalData"],
  beforeCreate() {
    this.form = this.$form.createForm(this, { name: "" });
  },
  methods: {
    phoneCheck(rule, value, callbackFn) {
      // const reg = /^[1][3,4,5,6,7,8,9][0-9]{9}$/  // 手机号正则
      // 电话号码正则表达式（支持手机号码，3-4位区号，7-8位直播号码，1－4位分机号）
      const reg =
        /^(\d{11})|^((\d{7,8})|(\d{4}|\d{3})-(\d{7,8})|(\d{4}|\d{3})-(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1})|(\d{7,8})-(\d{4}|\d{3}|\d{2}|\d{1}))$/;
      if (!reg.test(value)) {
        callbackFn("电话号码格式不正确");
        return;
      }
      callbackFn();
    },
  },
  watch: {
    visible(nVal) {
      if (nVal) {
        switch (this.opType) {
          case 0:
            this.title = "新增供应商";
            break;
          case 1:
            this.title = "编辑供应商";
            break;
        }
        this.$nextTick(() => {
          setTimeout(() => {
            if (this.modalData) {
              this.form.setFieldsValue({
                name: this.modalData.name,
                phone: this.modalData.phone,
                addr: this.modalData.addr,
                description: this.modalData.description,
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
          :title='title'
          @cancel="() => { $emit('cancel') }"
          @ok="() => { $emit('create') }"
        >
          <a-form layout='vertical' :form="form" class="vendorForm">
            <a-form-item label='供应商名称' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
              <a-input placeholder='请输入供应商名称'
                v-decorator="[
                  'name',
                  {
                    rules: [{ required: true, message: '请输入供应商名称' }],
                  }
                ]"
              />
            </a-form-item>
            <a-form-item label='电话号码' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
              <a-input placeholder='请输入电话号码'
                v-decorator="[
                  'phone',
                  {
                    rules: [{ required: true, message: '请输入电话号码' }, {validator:phoneCheck.bind(this)}],
                  }
                ]"
              />
            </a-form-item>
            <a-form-item label='地址信息' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
              <a-input placeholder='请输入地址信息'
                v-decorator="['addr']"
              />
            </a-form-item>
            <a-form-item label='描述' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
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
import {
  vendorlist,
  vendoradd,
  vendoredit,
  vendordel,
} from "@/services/vendor";
import { mapGetters, mapMutations, mapState, mapActions } from "vuex";
const columns = [
  {
    title: "序号",
    dataIndex: "index",
    scopedSlots: { customRender: "index" },
  },
  {
    title: "供应商名称",
    dataIndex: "name",
  },
  {
    title: "电话号码",
    dataIndex: "phone",
  },
  {
    title: "地址信息",
    dataIndex: "addr",
  },
  {
    title: "描述",
    dataIndex: "description",
  },
  {
    title: "操作",
    scopedSlots: { customRender: "action" },
  },
];

export default {
  name: "VendorManage",
  components: {
    StandardTable,
    vendorForm,
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
    ...mapGetters("vendor", ["vendorlist"]),
    ...mapState("setting", ["pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      console.log(this.pageMinHeight);
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
  },
  data() {
    return {
      advanced: true,
      columns: columns,
      dataSource: [],
      pagination: {
        current: 1,
        pageSize: 10,
        total: 0,
        showTotal: (total) => `共 ${total} 条数据`,
      },
      opType: 0,
      visible: false,
      modalData: null,
      spinning: true,
      searchText: "",
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    ...mapMutations("vendor", ["setVendorlist"]),
    ...mapActions("vendor", ["getAllVendors"]),
    onPageChange(page, pageSize) {
      this.pagination.current = page;
      this.pagination.pageSize = pageSize;
      this.getData();
    },
    getData() {
      this.spinning = true;
      vendorlist({
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
                this.dataSource = list;
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
    modifyVendor(data) {
      this.opType = 1;
      this.visible = true;
      this.modalData = data;
    },
    deleteVendor(data) {
      let self = this;
      this.$confirm({
        title: "删除供应商",
        content: "您确定要删除当前供应商吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          vendordel({
            id: [data.id],
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("删除成功");
                  self.getData();
                  // 更新缓存
                  self.getAllVendors();
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
    addNew() {
      this.opType = 0;
      this.visible = true;
      this.modalData = null;
    },
    handleCancel() {
      this.visible = false;
    },
    handleCreate() {
      const form = this.$refs.vendorForm.form;
      form.validateFields((err, values) => {
        if (err) {
          return;
        }
        console.log("Received values of form: ", values);
        if (this.opType === 0) {
          vendoradd({
            ...values,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  this.$message.info("添加成功");
                  this.visible = false;
                  this.getData();
                  // 更新缓存
                  this.getAllVendors();
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
          vendoredit({
            ...values,
            id: this.modalData.id,
          }).then((res) => {
            if (res) {
              if (res.errcode === 0) {
                this.$message.info("修改成功");
                this.visible = false;
                this.getData();
                // 更新缓存
                this.getAllVendors();
              } else {
                this.$message.error(res.errmsg);
              }
            } else {
              this.$message.error("服务异常， 请联系管理员");
            }
          });
        } else if (this.opType === 2) {
          console.log("查看详情的功能");
        }
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
  },
};
</script>
  
    <style lang="less" scoped>
.search {
  margin-bottom: 54px;
}
.fold {
  width: calc(100% - 216px);
  display: inline-block;
}
.operator {
  margin-bottom: 18px;
}
@media screen and (max-width: 900px) {
  .fold {
    width: 100%;
  }
}
/deep/ .ant-form-vertical .ant-form-item-label,
.ant-col-24.ant-form-item-label,
.ant-col-xl-24.ant-form-item-label {
  margin-right: 10px;
  text-align: right;
  line-height: 32px;
}
</style>
  