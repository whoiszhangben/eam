<template>
  <common-layout>
    <div class="top">
      <div class="header">
        <img src="../../assets/img/indexlogo.png" />
      </div>
      <div class="desc">欢迎使用宏凯集团资产云管理系统</div>
    </div>
    <div class="login">
      <a-form @submit="onSubmit" :form="form">
        <a-alert
          type="error"
          v-show="error"
          :message="error"
          showIcon
          style="margin-bottom: 24px"
        />
        <a-form-item>
          <a-input
            autocomplete="autocomplete"
            size="large"
            placeholder="请输入用户账号"
            v-decorator="[
              'account',
              {
                rules: [
                  { required: true, message: '请输入账户名', whitespace: true },
                ],
              },
            ]"
          >
            <a-icon slot="prefix" type="user" />
          </a-input>
        </a-form-item>
        <a-form-item>
          <a-input
            size="large"
            placeholder="请输入密码"
            autocomplete="autocomplete"
            type="password"
            v-decorator="[
              'password',
              {
                rules: [
                  { required: true, message: '请输入密码', whitespace: true },
                ],
              },
            ]"
          >
            <a-icon slot="prefix" type="lock" />
          </a-input>
        </a-form-item>
        <a-form-item style="text-align: center">
          <a-button
            :loading="logging"
            style="width: 100px; line-height: 24px; margin-top: 24px"
            size="large"
            htmlType="submit"
            type="primary"
            >登录</a-button
          >
        </a-form-item>
      </a-form>
    </div>
  </common-layout>
</template>

<script>
import CommonLayout from "@/layouts/CommonLayout";
import { login } from "@/services/user";
import { setAuthorization } from "@/utils/request";
import { mapMutations, mapActions } from "vuex";
import cryptoJS from "crypto-js";

export default {
  name: "Login",
  components: { CommonLayout },
  data() {
    return {
      logging: false,
      error: "",
      form: this.$form.createForm(this),
      isRememberPwd: true,
    };
  },
  computed: {
    systemName() {
      return this.$store.state.setting.systemName;
    },
  },
  methods: {
    ...mapMutations("account", ["setUser", "setPermissions", "setRoles"]),
    ...mapActions("organization", ["getOrganizations"]),
    ...mapActions("assetclassify", ["getAllClassifylist"]),
    ...mapActions("vendor", ["getAllVendors"]),
    onSubmit(e) {
      e.preventDefault();
      this.form.validateFields((err) => {
        if (!err) {
          this.logging = true;
          const account = this.form.getFieldValue("account");
          const password = cryptoJS
            .SHA256(account + this.form.getFieldValue("password"))
            .toString();
          login(account, password).then(this.afterLogin);
        }
      });
    },
    afterLogin(res) {
      this.logging = false;
      const loginRes = res;
      if (loginRes.errcode === 0) {
        const { name, id, account, role } = loginRes.data;
        this.setUser({ name, id, account, role });
        // this.setPermissions(permissions)
        this.setRoles([
          {
            id: role === 2 ? "user" : "admin",
          },
        ]);
        setAuthorization({
          token: loginRes.data.token,
          expireAt: new Date(loginRes.data.expireTime * 1000),
        });
        this.loadBaseData();
        this.$router.push("/home");
      } else {
        this.error = loginRes.errmsg;
      }
    },
    loadBaseData() {
      // 缓存一些基础数据
      this.getOrganizations();
      this.getAllClassifylist();
      this.getAllVendors();
    },
  },
};
</script>

<style lang="less" scoped>
.common-layout {
  .top {
    text-align: center;
    .header {
      height: 44px;
      line-height: 44px;
      color: #042275;
      font-size: 44px;
      font-weight: 750;
      a {
        text-decoration: none;
      }
      .logo {
        height: 44px;
        vertical-align: top;
        margin-right: 16px;
      }
      .title {
        font-size: 33px;
        color: @title-color;
        font-family: "Myriad Pro", "Helvetica Neue", Arial, Helvetica,
          sans-serif;
        font-weight: 600;
        position: relative;
        top: 2px;
      }
    }
    .desc {
      font-size: 14px;
      color: #999999;
      margin-top: 32px;
      margin-bottom: 40px;
    }
  }
  .login {
    width: 368px;
    margin: 60px auto;
    @media screen and (max-width: 576px) {
      width: 95%;
    }
    @media screen and (max-width: 320px) {
      .captcha-button {
        font-size: 14px;
      }
    }
    .icon {
      font-size: 24px;
      color: @text-color-second;
      margin-left: 16px;
      vertical-align: middle;
      cursor: pointer;
      transition: color 0.3s;

      &:hover {
        color: @primary-color;
      }
    }
  }
}
</style>
