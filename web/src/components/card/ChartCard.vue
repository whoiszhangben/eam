<template>
  <a-card
    :loading="loading"
    :body-style="{ padding: '20px 24px 8px' }"
    :bordered="false"
    class="zkCard"
  >
    <div class="cardStyle">
      <div class="left"><img :src="imgUrl" /></div>
      <div class="right">
        <div class="title">{{ title }}</div>
        <div class="content">
          <span class="value">{{ value }}</span
          ><span class="unit">{{ unit }}</span>
        </div>
      </div>
    </div>
  </a-card>
</template>

<script>
export default {
  name: "ChartCard",
  props: ["title", "value", "imgUrl", "unit", "loading"],
};
</script>

<style lang="less" scoped>
/deep/ .cardStyle {
  display: flex;
  flex-direction: row;
  align-items: center;
}

img {
  width: 54px;
  height: 54px;
}
.left {
  width: 100px;
  display: flex;
  align-items: center;
  justify-content: center;
}
.title {
  white-space: nowrap;
  margin: 10px 0;
}
.right {
  flex: 1;
  font-weight: 400;
  font-size: 14px;
  color: #999999;
}
.value {
  font-weight: 700;
  font-size: 32px;
  color: #333333;
}
.unit {
  margin-left: 10px;
}
.content {
  white-space: nowrap;
}
</style>
