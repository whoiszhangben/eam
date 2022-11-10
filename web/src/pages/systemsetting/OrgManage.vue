<template>
  <div class="orgDiv" :style="{ minHeight }">
    <div class="wrap">
      <a-tree
        ref="nodeTree"
        :tree-data="orgTree"
        :expandedKeys.sync="expandedKeys"
        default-expand-all
        show-icon
        @select="onSelect"
        :replaceFields="{ title: 'name', key: 'id', value: 'id' }"
      >
        <!--   新增、修改、删除图标   -->
        <template slot="plus" slot-scope="record">
          <a-icon
            type="plus"
            class="plusType"
            style="padding-left: 10px"
            @click.stop="nodeAddSub(record)"
            title="新增子机构"
          ></a-icon>
          <a-icon
            type="edit"
            class="editType"
            style="padding-left: 10px"
            @click.stop="nodeEdit(record)"
            title="编辑当前机构"
          ></a-icon>
          <a-icon
            type="delete"
            class="deleteType"
            style="padding-left: 10px"
            @click.stop="nodeDel(record)"
            title="删除当前机构"
          ></a-icon>
        </template>
      </a-tree>
    </div>
    <div class="orgdetail">
      <div v-if="selectOrg.id">
        <div class="orgTitle">详情</div>
        <div class="orgDesc">
          <p style="color: #1890ff">
            <span v-if="selectOrg.isdept || selectOrg.parent">
              {{ formatOrgStr() }}</span
            >
          </p>
          <p style="font-size: 16px; font-weight: 700; color: #1d2129">
            {{ selectOrg.name }}
          </p>
          <p style="color: #999999">{{ `- ${selectOrg.code} -` }}</p>
        </div>
      </div>
      <div v-else>
        <img src="../../assets/img/logo3.png" />
      </div>
    </div>
    <org-form
      ref="orgForm"
      :opType="opType"
      :visible="visible"
      :modalData="modalData"
      @cancel="handleCancel"
      @create="handleCreate"
    ></org-form>
  </div>
</template>

<script>
import { orgadd, orgedit, orgdel } from "@/services/organization";
import { mapState, mapGetters, mapMutations, mapActions } from "vuex";
import findAllParent from "@/utils/tree";
// 数组对象中查找符合目标的对象
const parseArray = function (objArray, key, value) {
  for (let i in objArray) {
    let element = objArray[i];
    if (typeof element === "object") {
      let result = parseArray(element, key, value);
      if (result) return result;
    } else {
      if (i === key) {
        if (element === value) return objArray;
      }
    }
  }
};
const OrgForm = {
  data() {
    return {
      title: "",
    };
  },
  props: ["visible", "opType", "modalData"],
  computed: {
    ...mapGetters("organization", [
      "selectOrg",
      "orgTree",
      "orgList",
      "deptList",
      "filterOrgTree",
    ]),
  },
  beforeCreate() {
    this.form = this.$form.createForm(this, { name: "" });
  },
  watch: {
    visible(nVal) {
      if (nVal) {
        switch (this.opType) {
          case 0:
            this.title = "新增子机构";
            break;
          case 1:
            this.title = "编辑机构";
            break;
        }
        console.log(
          "当前传入的modalData:",
          this.modalData,
          this.$parent.selectOrg
        );
        this.$nextTick(() => {
          setTimeout(() => {
            if (this.modalData) {
              this.form.setFieldsValue({
                name: this.modalData.name,
                code: this.modalData.code,
                isdept: this.modalData.isdept ? 1 : 0,
              });
            }
            if (this.opType === 0) {
              this.form.setFieldsValue({
                parent: this.$parent.selectOrg.name,
              });
            } else if (this.opType === 1) {
              let parentOrg = this.orgList.find(
                (item) => item.id === this.$parent.selectOrg.parent
              );
              this.form.setFieldsValue({
                parent: parentOrg ? parentOrg.name : "--",
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
        <a-form layout='vertical' :form="form" class="userForm">
          <a-form-item label='所属机构' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-input placeholder='请输入机构编码' :disabled="true"
              v-decorator="['parent']"
            />
          </a-form-item>
          <a-form-item label='机构编码' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-input placeholder='请输入机构编码'
              v-decorator="[
                'code',
                {
                  rules: [{ required: true, message: '请输入机构编码' }],
                }
              ]"
            />
          </a-form-item>
          <a-form-item label='机构名称' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-input placeholder='请输入机构名称'
              v-decorator="[
                'name',
                {
                  rules: [{ required: true, message: '请输入机构名称' }],
                }
              ]"
            />
          </a-form-item>
          <a-form-item label='部门标识' :labelCol="{span: 6}" :wrapperCol="{span: 13}">
            <a-radio-group placeholder='请输入机构名称'
              v-decorator="[
                'isdept',
                {
                  initialValue: 1,
                  rules: [{ required: true, message: '请输入机构名称' }],
                }
              ]"
            >
            <a-radio :value="1">是</a-radio>
            <a-radio :value="0">否</a-radio>
            </a-radio-group>
          </a-form-item>
        </a-form>
      </a-modal>
    `,
};

export default {
  name: "AssetClassify",
  components: {
    OrgForm,
  },
  computed: {
    ...mapGetters("organization", [
      "selectOrg",
      "orgTree",
      "orgList",
      "deptList",
      "filterOrgTree",
    ]),
    ...mapState("setting", ["pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
  },
  data() {
    return {
      expandedKeys: [],
      selectedKeys: null,
      selectNode: null,
      visible: false,
      opType: 0,
      modalData: null,
    };
  },
  mounted() {
    this.expandedKeys = [1, 3];
    if (!this.orgList.length) {
      this.getOrganizations();
    }
  },
  methods: {
    ...mapActions("organization", ["getOrganizations"]),
    ...mapMutations("organization", [
      "setSelectOrg",
      "setOrgTree",
      "setOrgList",
    ]),
    handleCancel() {
      this.visible = false;
    },
    handleCreate() {
      const form = this.$refs.orgForm.form;
      form.validateFields((err, values) => {
        if (err) {
          return;
        }
        console.log("Received values of form: ", values);
        if (this.opType === 0) {
          orgadd({
            name: values.name,
            code: values.code,
            isdept: values.isdept ? true : false,
            parent: this.selectOrg.id,
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  this.$message.info("添加成功");
                  this.visible = false;
                  this.getOrganizations().then(() => {
                    this.expandedKeys.push(this.selectOrg.id);
                  });
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
          orgedit({
            id: this.selectOrg.id,
            name: values.name,
            code: values.code,
            isdept: values.isdept ? true : false,
            parent: this.selectOrg.parent,
          }).then((res) => {
            if (res) {
              if (res.errcode === 0) {
                this.$message.info("修改成功");
                this.visible = false;
                this.getOrganizations().then(() => {
                  this.expandedKeys.push(this.selectOrg.id);
                });
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
    nodeAddSub() {
      this.opType = 0;
      this.visible = true;
      this.modalData = null;
    },
    nodeEdit(node) {
      this.opType = 1;
      this.visible = true;
      this.modalData = node;
    },
    nodeDel(node) {
      let self = this;
      var tips = "";
      if (Array.isArray(node.children) && node.children.length > 0) {
        tips = "删除当前机构会同步删除该机构下的子机构，您确定要删除吗?";
      } else {
        tips = "您确定要删除当前机构吗？";
      }
      this.$confirm({
        title: "删除机构",
        content: tips,
        okText: "确认",
        cancelText: "取消",
        onOk() {
          orgdel({
            id: [self.selectOrg.id],
          })
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  self.$message.info("删除成功");
                  self.getOrganizations().then(() => {
                    console.log("hahhahahah1", self.selectOrg.parent);
                    self.selectNode = parseArray(
                      self.orgTree,
                      "id",
                      self.selectOrg.parent
                    );
                    console.log("hahhahahah2", self.selectNode);
                    self.setSelectOrg(self.selectNode);
                    self.expandedKeys.push(self.selectOrg.parent);
                    self.selectedKeys = [self.selectOrg.parent];
                  });
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
    async onSelect(params, e) {
      if (this.selectNode) {
        this.$set(this.selectNode, "scopedSlots", {});
      }
      // 节点选中或取消选中
      if (e.selected) {
        // 树节点中查找到对应的当前节点，添加scopedSlots属性
        this.selectNode = parseArray(this.orgTree, "id", params[0]);
        this.setSelectOrg(this.selectNode);
        let iconStr = "plus";
        this.$set(this.selectNode, "scopedSlots", { icon: iconStr });
        this.selectedKeys = params;
      } else {
        this.selectedKeys = null;
      }
    },
    findAllParent,
    formatOrgStr() {
      let orgParent = this.findAllParent(this.selectOrg, this.orgTree);
      if (Array.isArray(orgParent)) {
        let parentArr = orgParent.map((item) => item.name);
        return parentArr.reverse().join("/");
      }
      return "--";
    },
  },
};
</script>

  <style lang="less" scoped>
.orgDiv {
  display: flex;
  flex-flow: row;
}
.wrap {
  position: relative;
  width: 350px;
  background: #fff;
}
.orgdetail {
  position: relative;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
  border-left: 1px solid #ebebeb;
}
/deep/.ant-tree li span.ant-tree-iconEle {
  width: 14px;
  height: 14px;
  position: absolute;
  right: 70px;
  .plusType,
  .editType,
  .deleteType {
    &:hover {
      color: @primary-color;
    }
  }
}
/deep/.ant-tree-node-content-wrapper {
  max-width: 190px;
  overflow: hidden;
  text-overflow: ellipsis;
}

/deep/ .ant-form-vertical .ant-form-item-label,
.ant-col-24.ant-form-item-label,
.ant-col-xl-24.ant-form-item-label {
  margin-right: 10px;
  text-align: right;
  line-height: 32px;
}
.orgTitle {
  position: absolute;
  width: 100%;
  background: #fafafa;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  top: 0;
  left: 0;
  line-height: 40px;
  padding-left: 26px;
}
.orgDesc {
  display: flex;
  flex-flow: column;
  align-items: center;
  justify-content: center;
}
</style>