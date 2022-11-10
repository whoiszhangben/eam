<template>
  <div>
    <a-modal
      :maskClosable="false"
      :title="'打印资产条码'"
      :visible="printModalVisible"
      @cancel="handleCancel"
      width="640px"
    >
      <div>
        <a-row class="center">
          <a-col :offset="4" :span="4">选择打印机</a-col>
          <a-col :span="8">
            <a-select v-model="currentId" style="width: 100%">
              <a-select-option v-for="item in printList" :key="item.id">{{
                `${item.name}`
              }}</a-select-option>
            </a-select>
          </a-col>
        </a-row>
        <a-row>
          <a-col :offset="4" :span="16">
            <a-alert
              type="error"
              message="系统检测没有可连接的打印机，请连接打印机后再打印"
              v-if="forbiddenPrint"
              banner
            />
          </a-col>
        </a-row>
      </div>
      <template slot="footer">
        <a-button @click="handleCancel"> 取消 </a-button>
        <a-button :disabled="forbiddenPrint" @click="handlePrint">
          确定
        </a-button>
      </template>
    </a-modal>
  </div>
</template>
  
  <script>
import { printlist } from "@/services/goods";
export default {
  name: "PrintModal",
  data() {
    return {
      forbiddenPrint: false,
      currentId: "",
      printList: [],
    };
  },
  props: ["printModalVisible"],
  methods: {
    handleCancel() {
      this.$emit("close");
    },
    getPrintList() {
      printlist()
        .then((res) => {
          if (res) {
            if (res.errcode === 0) {
              let cachedId = localStorage.getItem("printOption");
              let hasValue = Array.isArray(res.data) && res.data.length > 0;
              if (!hasValue) {
                this.forbiddenPrint = true;
                this.currentId = undefined;
              } else {
                this.forbiddenPrint = false;
                this.printList = res.data;
                let printIndex = res.data.findIndex((x) => x.id === cachedId);
                if (printIndex === -1) {
                  this.currentId = res.data[0].id;
                } else {
                  this.currentId = cachedId;
                }
              }
            } else {
              this.$message.error(res.errmsg);
            }
          } else {
            this.$message.error("服务异常， 请联系管理员");
          }
        })
        .catch((err) => {
          console.log(err);
        });
    },
    handlePrint() {
      if (!this.currentId) {
        this.$message.info("未选择打印机");
        return;
      }
      this.$emit("printAsset", this.currentId);
      this.$emit("close");
    },
  },
  watch: {
    printModalVisible(nVal) {
      if (nVal) {
        this.getPrintList();
      } else {
        this.currentId = undefined;
      }
    },
  },
};
</script>
  
  <style lang="less" scoped>
/deep/ .ant-form-vertical .ant-form-item-label,
.ant-col-24.ant-form-item-label,
.ant-col-xl-24.ant-form-item-label {
  text-align: right;
  margin: 5px 15px 0 0;
}
/deep/ .ant-alert-error {
  background: transparent;
}
.center {
  display: flex;
  align-items: center;
}
</style>