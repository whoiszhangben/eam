<template>
  <div>
    <v-chart
      :forceFit="true"
      :height="height"
      :data="sourceData"
      :scale="scale"
    >
      <v-tooltip
        :useHtml="true"
        :htmlContent="
          (title, items) => {
            let tpl = '';
            items.forEach((item) => {
              if (item.name !== 'total') {
                tpl += `<li><span>${item.name}</span><span style='margin: 0 15px'>${item.value}</span><span style='font-weight: 700'>元</span></li>`;
              }
            });
            return `<div style='background-color:#fff;position:absolute;'><ul style='padding: 15px 30px 0; list-style-type: none;'>${tpl}</ul></div>`;
          }
        "
      />
      <v-axis />
      <v-smooth-line position="title*total" color="alias" shape="smooth" />
      <v-smooth-area position="title*total" color="rgba(116,188,255,0.2)" />
      <v-point position="title*total" shape="circle" />
    </v-chart>
  </div>
</template>
  
  <script>
const scale = [
  {
    dataKey: "total",
    min: 0,
  },
  {
    dataKey: "title",
    min: 0,
    max: 1,
  },
];

export default {
  data() {
    return {
      scale,
      height: 400,
    };
  },
  mounted() {
    console.log(this.sourceData);
  },
  props: ["sourceData"],
  filters: {
    //格式化字符串
    formatNum(num) {
      // 如果val小于1000, 整数直接返回，小数转两位
      if (num < 1000) {
        if (Number.isInteger(num)) {
          return num.toString();
        } else {
          return num.toFixed(2);
        }
      } else if (num < 10000) {
        if (Number.isInteger(num)) {
          return (num + "").replace(/\d{1,3}(?=(\d{3})+(\.\d*)?$)/g, "$&,");
        } else {
          return (num.toFixed(2) + "").replace(
            /\d{1,3}(?=(\d{3})+(\.\d*)?$)/g,
            "$&,"
          );
        }
      } else if (num < 100000000) {
        return `${(num / 10000).toFixed(2)}万`;
      } else {
        return `${(num / 100000000).toFixed(2)}亿`;
      }
    },
  },
};
</script>
  