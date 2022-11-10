<template>
  <a-dropdown>
    <div class="header-avatar" style="cursor: pointer">
      <a-avatar
        class="avatar"
        size="small"
        shape="circle"
        :src="user.avatar || avatar"
      />
      <span class="name">{{ user.name }}</span>
    </div>
    <a-menu :class="['avatar-menu']" slot="overlay">
      <a-menu-item @click="logout">
        <a-icon style="margin-right: 8px" type="poweroff" />
        <span>退出登录</span>
      </a-menu-item>
    </a-menu>
  </a-dropdown>
</template>

<script>
import { mapGetters } from "vuex";
import { logout } from "@/services/user";
import avatar from "@/assets/img/avatar.png";

export default {
  name: "HeaderAvatar",
  computed: {
    ...mapGetters("account", ["user"]),
  },
  data() {
    return {
      avatar,
    };
  },
  methods: {
    logout() {
      logout();
      this.$router.push("/login");
    },
  },
};
</script>

<style lang="less">
.header-avatar {
  display: inline-flex;
  .avatar,
  .name {
    align-self: center;
  }
  .avatar {
    margin-right: 8px;
  }
  .name {
    font-weight: 500;
  }
}
.avatar-menu {
  width: 150px;
}
</style>
