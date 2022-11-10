<template>
  <a-card :style="{ minHeight }">
    <a-spin :spinning="spinning">
      <div>
        <a-row style="color: #333333; font-weight: 700">
          <a-col :span="24">
            {{ currentAssetClassify.name }}
          </a-col>
        </a-row>
        <a-divider></a-divider>
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
            <a-button @click="addNew" type="primary">新增子分类</a-button>
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
          <div slot="code" slot-scope="{ text }">
            {{ `${currentAssetClassify.code} - ${text}` }}
          </div>
          <div slot="action" slot-scope="{ text, record }">
            <a style="margin-right: 8px" @click="modifySubCategory(record)">
              修改
            </a>
            <a
              @click="deleteSubCategory(record)"
              style="color: #ff1818; margin-right: 8px"
            >
              删除
            </a>
          </div>
        </standard-table>
      </div>
    </a-spin>
    <sub-category-form
      ref="subCategoryForm"
      :opType="opType"
      :visible="visible"
      :modalData="modalData"
      :parent="currentAssetClassify"
      @cancel="handleCancel"
      @create="handleCreate"
    ></sub-category-form>
  </a-card>
</template>
  
    <script>
import { mapGetters, mapState, mapActions } from "vuex";
import {
  childcatlist,
  childcatadd,
  childcatedit,
  childcatdel,
} from "@/services/category";
const SubCategoryForm = {
  data() {
    return {
      title: "",
    };
  },
  props: ["visible", "opType", "modalData", "parent"],
  beforeCreate() {
    this.form = this.$form.createForm(this, { name: "" });
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
    ...mapGetters("assetclassify", ["classifylist"]),
  },
  watch: {
    visible(nVal) {
      if (nVal) {
        switch (this.opType) {
          case 0:
            this.title = "新增资产分类";
            break;
          case 1:
            this.title = "编辑资产分类";
            break;
        }
        this.$nextTick(() => {
          setTimeout(() => {
            if (this.modalData) {
              this.form.setFieldsValue({
                gsortid: this.parent.id,
                pcode: this.parent.code,
                name: this.modalData.name,
                code: this.modalData.code,
                description: this.modalData.description,
              });
            } else {
              this.form.setFieldsValue({
                gsortid: this.parent.id,
                pcode: this.parent.code,
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
          <a-form layout='vertical' :form="form" class="subCategoryForm">
            <a-form-item label='所属分类' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
                <a-select v-decorator="[
                    'gsortid',
                    {
                      rules: [{ required: true, message: '请选择所属分类' }],
                    }
                  ]" placeholder="请选择" :disabled="true">
                    <a-select-option v-for="item in classifylist" :key="item.id">{{ item.name }}</a-select-option>
                  </a-select>
            </a-form-item>
            <a-form-item label='资产子分类编码' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
                <a-row>
                    <a-col :span='6'>
                        <a-input  v-decorator="[
                  'pcode'
                ]"
                :disabled="true"
            />
                    </a-col>
                    <a-col :span='2' style='display:flex; align-items: center; justify-content: center; line-height: 32px; color: #DDDDDD;'>-</a-col>
                    <a-col :span='16'>
                        <a-input placeholder='请输入资产子分类编码'
                v-decorator="[
                  'code',
                  {
                    rules: [{ required: true, message: '请输入资产子分类编码' }],
                  }
                ]"
              />
                        </a-col>
                </a-row>              
            </a-form-item>
            <a-form-item label='资产子分类名称' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
              <a-input
                v-decorator="[
                  'name',
                  {
                    rules: [{ required: true, message: '请输入资产子分类名称' }],
                  }
                ]"
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

const columns = [
  {
    title: "序号",
    dataIndex: "index",
    scopedSlots: { customRender: "index" },
  },
  {
    title: "资产子分类编号",
    dataIndex: "code",
    scopedSlots: { customRender: "code" },
  },
  {
    title: "资产子分类名称",
    dataIndex: "name",
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
  name: "AssetSubClassify",
  components: {
    StandardTable,
    SubCategoryForm,
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
    ...mapGetters("assetclassify", ["classifylist"]),
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
      currentAssetClassify: Object.create(null),
    };
  },
  mounted() {
    if (!this.classifylist.length) {
      this.getAllClassifylist().then(() => {
        console.log("----this.classifylist:", this.classifylist);
        let pId = Number(this.$route.params.id);
        this.currentAssetClassify = this.classifylist.find((x) => x.id === pId);
        this.getData();
      });
    } else {
      let pId = Number(this.$route.params.id);
      this.currentAssetClassify = this.classifylist.find((x) => x.id === pId);
      this.getData();
    }
  },
  methods: {
    ...mapActions("assetclassify", ["getAllClassifylist"]),
    onPageChange(page, pageSize) {
      this.pagination.current = page;
      this.pagination.pageSize = pageSize;
      this.getData();
    },
    getData() {
      this.spinning = true;
      childcatlist({
        pagination: {
          pageSize: this.pagination.pageSize,
          sortBy: "",
          page: this.pagination.current,
        },
        keyword: this.searchText,
        gsortid: [this.currentAssetClassify.id],
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
    modifySubCategory(data) {
      this.opType = 1;
      this.visible = true;
      this.modalData = data;
    },
    deleteSubCategory(data) {
      let self = this;
      this.$confirm({
        title: "删除子分类",
        content: "您确定要删除当前资产子分类吗？",
        okText: "确认",
        cancelText: "取消",
        onOk() {
          childcatdel({
            id: [data.id],
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("删除成功");
                  self.getData();
                  self.getAllClassifylist();
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
      const form = this.$refs.subCategoryForm.form;
      form.validateFields((err, values) => {
        if (err) {
          return;
        }
        console.log("Received values of form: ", values);
        if (this.opType === 0) {
          childcatadd({
            name: values.name,
            code: values.code,
            gsortid: values.gsortid,
            description: values.description,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  this.$message.info("添加成功");
                  this.visible = false;
                  this.getData();
                  this.getAllClassifylist();
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
          childcatedit({
            ...values,
            id: this.modalData.id,
          }).then((res) => {
            if (res) {
              if (res.errcode === 0) {
                this.$message.info("修改成功");
                this.visible = false;
                this.getData();
                this.getAllClassifylist();
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
  