<template>
  <div :class="['page-header', layout, pageWidth]">
    <div class="page-header-wide">
      <div class="breadcrumb">
        <a-breadcrumb>
          <a-breadcrumb-item
            :key="index"
            v-for="(item, index) in breadcrumb"
            :href="item.path"
          >
            <span v-if="index === breadcrumb.length - 1">
              {{ item.name }}
            </span>
            <router-link v-else :to="`${item.path}`">
              {{ item.name }}
            </router-link>
          </a-breadcrumb-item>
        </a-breadcrumb>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
export default {
  name: "PageHeader",
  props: {
    title: {
      type: [String, Boolean],
      required: false,
    },
    breadcrumb: {
      type: Array,
      required: false,
    },
    logo: {
      type: String,
      required: false,
    },
    avatar: {
      type: String,
      required: false,
    },
  },
  computed: {
    ...mapState("setting", ["layout", "showPageTitle", "pageWidth"]),
  },
};
</script>

<style lang="less" scoped>
@import "index";
</style>
