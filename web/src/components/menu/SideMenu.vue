<template>
  <a-layout-sider
    :theme="sideTheme"
    :class="['side-menu', 'beauty-scroll', isMobile ? null : 'shadow']"
    width="256px"
    :collapsible="collapsible"
    v-model="collapsed"
    :trigger="null"
  >
    <div :class="['logo', theme]">
      <router-link v-if="!collapsed" to="/">
        <img src="@/assets/img/logo.png" />
      </router-link>
      <router-link v-if="collapsed" to="/">
        <img style="width: 30px" src="@/assets/img/logo2.png" />
      </router-link>
    </div>
    <i-menu
      :theme="theme"
      :collapsed="collapsed"
      :options="menuData"
      @select="onSelect"
      class="menu"
    />
  </a-layout-sider>
</template>

<script>
import IMenu from "./menu";
import { mapState } from "vuex";
export default {
  name: "SideMenu",
  components: { IMenu },
  props: {
    collapsible: {
      type: Boolean,
      required: false,
      default: false,
    },
    collapsed: {
      type: Boolean,
      required: false,
      default: false,
    },
    menuData: {
      type: Array,
      required: true,
    },
    theme: {
      type: String,
      required: false,
      default: "dark",
    },
  },
  computed: {
    sideTheme() {
      return this.theme == "light" ? this.theme : "dark";
    },
    ...mapState("setting", ["isMobile", "systemName"]),
  },
  methods: {
    onSelect(obj) {
      this.$emit("menuSelect", obj);
    },
  },
};
</script>

<style lang="less" scoped>
@import "index";
</style>
