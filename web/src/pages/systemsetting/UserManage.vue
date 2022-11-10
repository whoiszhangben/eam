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
            <a-button @click="addNew" type="primary">新增用户</a-button>
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
          <div slot="role" slot-scope="{ text }">
            {{ text === 1 ? "管理员" : "用户" }}
          </div>
          <div slot="ctime" slot-scope="{ text }">
            {{ momentFormat(text) }}
          </div>
          <div slot="action" slot-scope="{ text, record }">
            <a style="margin-right: 8px" @click="modifyUser(record)"> 编辑 </a>
            <a style="margin-right: 8px" @click="modifyPwd(record)">
              重置密码</a
            >
            <a
              @click="deleteUser(record)"
              style="color: #ff1818"
              v-if="currUser.id !== record.id"
              >删除
            </a>
          </div>
          <template slot="statusTitle">
            <a-icon @click.native="onStatusTitleClick" type="info-circle" />
          </template>
        </standard-table>
      </div>
    </a-spin>
    <user-form
      ref="userForm"
      :visible="visible"
      :modalData="modalData"
      :opType="opType"
      @cancel="handleCancel"
      @create="handleCreate"
    ></user-form>
  </a-card>
</template>

  <script>
const UserForm = {
  data() {
    return {
      title: "",
      dataForm: {
        name: "",
        account: "",
        password: "",
        confirmPassword: "",
        role: 0,
        description: "",
      },
      confirmDirty: true,
    };
  },
  props: ["visible", "opType", "modalData"],
  beforeCreate() {
    this.form = this.$form.createForm(this, { name: "" });
  },
  mounted() {
    console.log("执行mounted");
  },
  watch: {
    visible(nVal) {
      if (nVal) {
        switch (this.opType) {
          case 0:
            this.title = "新增用户";
            break;
          case 1:
            this.title = "编辑用户";
            break;
          default:
            this.title = "修改密码";
            break;
        }
        console.log("当前传入的modalData:", this.modalData);
        this.$nextTick(() => {
          setTimeout(() => {
            if (this.modalData) {
              if (this.opType === 1) {
                this.form.setFieldsValue({
                  name: this.modalData.name,
                  account: this.modalData.account,
                  role: this.modalData.role,
                  description: this.modalData.description,
                });
              } else if (this.opType === 2) {
                this.form.setFieldsValue({
                  name: this.modalData.name,
                  account: this.modalData.account,
                });
              }
            }
          }, 1);
        });
      } else {
        this.form.resetFields();
      }
    },
  },
  methods: {
    // 密码确认
    compareToFirstPassword(rule, value, callback) {
      const form = this.form;
      if (value && value !== form.getFieldValue("password")) {
        callback("请确认两次输入密码的一致性！");
      } else {
        callback();
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
        <a-form layout='vertical' :form="form" class="userForm">
          <a-form-item label='账号' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-input placeholder='请输入账号' :disabled="opType !== 0"
              v-decorator="[
                'account',
                {
                  rules: [{ required: true, message: '请输入账号' }],
                }
              ]"
            />
          </a-form-item>
          <a-form-item label='姓名' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-input placeholder='请输入姓名' :disabled="opType === 2"
              v-decorator="[
                'name',
                {
                  rules: [{ required: true, message: '请输入姓名' }],
                }
              ]"
            />
          </a-form-item>
          <a-form-item label='密码' :labelCol="{span: 6}" :wrapperCol="{span: 13}" v-if="opType !== 1">
            <a-input-password placeholder='请输入密码'
              v-decorator="[
                'password',
                {
                  rules: [{ required: true, message: '请输入密码' },],
                }
              ]"
            />
          </a-form-item>
          <a-form-item label='确认密码' :labelCol="{span: 6}" :wrapperCol="{span: 13}" v-if="opType !== 1">
            <a-input-password placeholder='请再次输入密码'
              v-decorator="[
                'confirmPassword',
                {
                  rules: [{ required: true, message: '请再次输入密码' },{ validator: compareToFirstPassword },],
                }
              ]"
            />
          </a-form-item>
          <a-form-item label='角色' :labelCol="{span: 6}" :wrapperCol="{span: 13}" v-if="opType !== 2">
            <a-select v-decorator="[
              'role', {
                rules: [{ required: true, message: '请选择角色'}]
              }
            ]" placeholder="请选择角色">
              <a-select-option :value="1">管理员</a-select-option>
              <a-select-option :value="2">用户</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label='描述' :labelCol="{span: 6}" :wrapperCol="{span: 13}" v-if="opType !== 2">
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
// import UserModal from '@/components/dialog/userModal'
import { userlist, useradd, userdel, useredit } from "@/services/user";
import cryptoJS from "crypto-js";
import moment from "moment";
import { mapState } from "vuex";
const columns = [
  {
    title: "序号",
    dataIndex: "index",
    scopedSlots: { customRender: "index" },
  },
  {
    title: "账号",
    dataIndex: "account",
  },
  {
    title: "名称",
    dataIndex: "name",
  },
  {
    title: "角色",
    dataIndex: "role",
    scopedSlots: { customRender: "role" },
  },
  {
    title: "描述",
    dataIndex: "description",
  },
  {
    title: "更新时间",
    dataIndex: "ctime",
    scopedSlots: { customRender: "ctime" },
    sorter: true,
  },
  {
    title: "操作",
    scopedSlots: { customRender: "action" },
  },
];

export default {
  name: "UserManage",
  components: {
    StandardTable,
    UserForm,
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
    ...mapState("setting", ["lang", "pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
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
    this.getData();
  },
  methods: {
    onPageChange(page, pageSize) {
      this.pagination.current = page;
      this.pagination.pageSize = pageSize;
      this.getData();
    },
    getData() {
      this.spinning = true;
      userlist({
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
    deleteRecord(key) {
      this.dataSource = this.dataSource.filter((item) => item.key !== key);
      this.selectedRows = this.selectedRows.filter((item) => item.key !== key);
    },
    toggleAdvanced() {
      this.advanced = !this.advanced;
    },
    remove() {
      this.dataSource = this.dataSource.filter(
        (item) =>
          this.selectedRows.findIndex((row) => row.key === item.key) === -1
      );
      this.selectedRows = [];
    },
    addNew() {
      this.opType = 0;
      this.visible = true;
      this.modalData = null;
    },
    batchDel() {
      this.$message.info("此功能正在开发中");
    },
    search() {
      this.getData();
    },
    reset() {
      this.searchText = "";
      this.getData();
    },
    modifyUser(user) {
      this.opType = 1;
      this.visible = true;
      this.modalData = user;
      console.log(user);
    },
    modifyPwd(user) {
      this.opType = 2;
      this.visible = true;
      this.modalData = user;
      console.log(user);
    },
    deleteUser(data) {
      let self = this;
      this.$confirm({
        title: "删除用户",
        content: "您确定要删除当前用户吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          userdel({
            id: [data.id],
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("删除成功");
                  self.getData();
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
    submit() {},
    handleCancel() {
      this.visible = false;
    },
    handleCreate() {
      const form = this.$refs.userForm.form;
      form.validateFields((err, values) => {
        if (err) {
          return;
        }
        console.log("Received values of form: ", values);
        if (this.opType === 0) {
          useradd({
            ...values,
            password: cryptoJS
              .SHA256(values.account + values.password)
              .toString(),
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
        } else if (this.opType === 1) {
          // todo 编辑
          useredit({
            ...values,
            id: this.modalData.id,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  this.$message.info("修改成功");
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
        } else if (this.opType === 2) {
          useredit({
            id: this.modalData.id,
            password: cryptoJS
              .SHA256(values.account + values.password)
              .toString(),
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  this.$message.info("密码重置成功");
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
        }
      });
    },
    momentFormat(date, type = "YYYY-MM-DD HH:mm:ss") {
      return moment(date).format(type);
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
  line-height: 32px;
}
.assetDivider {
  margin: 0 0 24px;
  & /deep/ .ant-divider,
  .ant-divider-vertical {
    top: 0;
  }
}
</style>
