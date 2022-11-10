<template>
  <a-card class="mylayout" :style="{ minHeight }">
    <div class="mycontainer">
      <div class="wrapcont">
        <span class="title">数据库备份</span>
        <span class="desc"
          >做好数据库备份可以最大程度的避免数据丢失,
          请根据情况设置备份周期</span
        >
      </div>
      <div class="dbback margin10" v-if="isEdit">
        <a-row>
          <a-col :span="7">备份周期(单位:天) </a-col>
          <a-col :span="12"><a-input v-model="dbbackcycle"></a-input></a-col>
        </a-row>
      </div>
      <div class="dbback margin10" v-else>
        <a-row>
          <a-col :span="7">备份周期(单位:天) </a-col>
          <a-col :span="17">{{ dbbackcycle }}</a-col>
        </a-row>
      </div>
      <div class="dbback" v-if="isEdit">
        <a-row>
          <a-col :span="7">备份路径 </a-col>
          <a-col :span="12"><a-input v-model="dbbackpath"></a-input></a-col>
        </a-row>
      </div>
      <div class="dbback" v-else>
        <a-row>
          <a-col :span="7">备份路径 </a-col>
          <a-col :span="7">{{ dbbackpath }}</a-col>
        </a-row>
      </div>
      <div class="dbBtns">
        <a-button type="primary" @click="edit" class="dbBtn">{{
          btnText
        }}</a-button>
        <a-button v-if="isEdit" @click="cancel">取消</a-button>
      </div>
    </div>
  </a-card>
</template>

<script>
import { mapState, mapActions, mapGetters } from "vuex";
import { paramsedit } from "@/services/sysparams";
export default {
  name: "ParamsSetting",
  data() {
    return {
      dbbackcycle: 1,
      dbbackpath: "",
      btnText: "编辑",
      isEdit: false,
    };
  },
  computed: {
    ...mapGetters("systemparams", ["systemparams"]),
    ...mapState("setting", ["pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
  },
  created() {
    this.getSystemParams();
  },
  methods: {
    ...mapActions("systemparams", ["getSystemParams"]),
    onChange(checked) {
      console.log(`a-switch to ${checked}`);
    },
    cancel() {
      this.isEdit = false;
      this.btnText = "编辑";
    },
    edit() {
      if (!this.isEdit) {
        this.isEdit = !this.isEdit;
        this.btnText = "保存";
        return;
      }

      paramsedit({
        database: {
          backupPeriod: Number(this.dbbackcycle),
          backupPath: this.dbbackpath,
        },
      })
        .then((res) => {
          if (res && res.errcode === 0) {
            this.$message.info("保存成功");
            this.isEdit = false;
            this.btnText = "编辑";
            this.getSystemParams();
          }
        })
        .catch((err) => {
          this.$message.error(err.message);
        });
    },
  },
  watch: {
    "systemparams.database"(nVal) {
      if (nVal) {
        this.dbbackcycle = nVal.backupPeriod;
        this.dbbackpath = nVal.backupPath;
      }
    },
  },
};
</script>

<style lang="less" scoped>
.mycontainer {
  width: 500px;
}
.title {
  color: #111218;
  font-weight: 600;
}
.desc {
  font-size: 12px;
  color: rgba(17, 18, 24, 0.5);
  padding-left: 8px;
}
.dbback {
  line-height: 40px;
  overflow: hidden;
}
.margin10 {
  margin-top: 10px;
}
.dbBtns {
  display: flex;
  justify-content: center;
  margin: 15px;
}
.dbBtn {
  margin-right: 15px;
}
</style>