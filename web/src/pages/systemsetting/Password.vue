<template>
  <a-card :style="{ minHeight }">
    <a-form-model
      ref="ruleForm"
      :model="ruleForm"
      :rules="rules"
      v-bind="layout"
    >
      <a-form-model-item label="旧密码" prop="oldPassword">
        <a-input
          v-model="ruleForm.oldPassword"
          type="password"
          autocomplete="off"
        />
      </a-form-model-item>
      <a-form-model-item label="新密码" prop="newPassword">
        <a-input
          v-model="ruleForm.newPassword"
          type="password"
          autocomplete="off"
        />
      </a-form-model-item>
      <a-form-model-item label="确认新密码" prop="checkNewPass">
        <a-input
          v-model="ruleForm.checkNewPass"
          type="password"
          autocomplete="off"
        />
      </a-form-model-item>
      <a-form-model-item :wrapper-col="{ span: 14, offset: 8 }">
        <a-button type="primary" @click="submitForm('ruleForm')">
          提交修改
        </a-button>
        <a-button style="margin-left: 10px" @click="resetForm('ruleForm')">
          重置
        </a-button>
      </a-form-model-item>
    </a-form-model>
  </a-card>
</template>

<script>
import { mapState } from "vuex";
import { userpwdmodify } from "@/services/user";
import cryptoJS from "crypto-js";
export default {
  name: "Password",
  data() {
    let validoldPass = (rule, value, callback) => {
      if (value === "") {
        callback(new Error("请输入当前密码"));
      }
      callback();
    };
    let validatePass = (rule, value, callback) => {
      if (value === "") {
        callback(new Error("请输入新密码"));
      } else {
        if (this.ruleForm.checkNewPass !== "") {
          this.$refs.ruleForm.validateField("checkNewPass");
        }
        callback();
      }
    };
    let validatePass2 = (rule, value, callback) => {
      if (value === "") {
        callback(new Error("请再次输入新密码"));
      } else if (value !== this.ruleForm.newPassword) {
        callback(new Error("两次输入的新密码不匹配"));
      } else {
        callback();
      }
    };
    return {
      ruleForm: {
        oldPassword: "",
        newPassword: "",
        checkNewPass: "",
      },
      rules: {
        oldPassword: [{ validator: validoldPass, trigger: "change" }],
        newPassword: [{ validator: validatePass, trigger: "change" }],
        checkNewPass: [{ validator: validatePass2, trigger: "change" }],
      },
      layout: {
        labelCol: { span: 6 },
        wrapperCol: { span: 10 },
      },
    };
  },
  computed: {
    ...mapState("account", { currUser: "user" }),
    ...mapState("setting", ["lang", "pageMinHeight", "correctPageMinHeight"]),
    minHeight() {
      return this.pageMinHeight ? this.pageMinHeight - 66 + "px" : "100vh";
    },
  },
  methods: {
    submitForm(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          let params = {
            id: this.currUser.id,
            oldPassword: cryptoJS
              .SHA256(this.currUser.account + this.ruleForm.oldPassword)
              .toString(),
            newPassword: cryptoJS
              .SHA256(this.currUser.account + this.ruleForm.newPassword)
              .toString(),
          };
          console.log(params);
          userpwdmodify(params)
            .then((res) => {
              if (res) {
                if (res.errcode === 0) {
                  this.$message.info("修改成功");
                } else {
                  this.$message.error(res.errmsg);
                }
              } else {
                this.$message.error("服务异常， 请联系管理员");
              }
            })
            .catch((err) => {
              console.log(err.message);
              this.$message.error(err.message);
            });
        } else {
          console.log("error submit!!");
          return false;
        }
      });
    },
    resetForm(formName) {
      this.$refs[formName].resetFields();
    },
  },
};
</script>

<style lang="less" scoped>
.pwdLayout {
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>