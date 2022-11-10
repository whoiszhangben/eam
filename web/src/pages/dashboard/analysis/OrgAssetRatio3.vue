<template>
  <div style="">
    <v-chart
      :forceFit="true"
      :height="height"
      :data="data"
      :scale="scale"
      :padding="[32, 30, 38, 10]"
    >
      <v-tooltip :showTitle="false" dataKey="item*percent*count" />
      <v-axis />
      <v-legend
        dataKey="item"
        :useHtml="true"
        position="bottom-center"
        :reactive="true"
        :containerTpl="containerTplLegend"
        :itemTpl="itemTplLegend"
      ></v-legend>
      <v-pie
        position="percent"
        color="item"
        :vStyle="pieStyle"
        :label="labelConfig"
        :tooltip="tooltip"
      />
      <v-coord type="theta" :innerRadius="0.65" />
    </v-chart>
  </div>
</template>

<script>
const DataSet = require("@antv/data-set");

const scale = [
  {
    dataKey: "percent",
    min: 0,
    formatter: (val) => {
      return (val * 100).toFixed(2) + "%";
    },
  },
  {},
];
export default {
  name: "OrgAssetRatio",
  data() {
    return {
      data: [],
      scale,
      height: 220,
      pieStyle: {
        stroke: "#fff",
        lineWidth: 1,
      },
      labelConfig: [
        "percent",
        {
          formatter: (val, item) => {
            return item.point.item + ": " + val;
          },
        },
      ],
      dv: null,
      containerTplLegend: `<div class="g2-legend"><table class="g2-legend-list zkdefine"></table></div>`,
      itemTplLegend: (value, color, checked, index) => {
        checked = checked ? "checked" : "unChecked";
        return `<tr class="g2-legend-list-item item-${index} ${checked}" data-value="${value}" data-color="${color}" style="display: block;">
          <td style="min-width: 100px; text-align: left;line-height:32px">
            <i class="g2-legend-marker" style="width:10px; height:10px; display:inline-block; padding-left:10px; background-color:${color}; margin-bottom: 3px;"></i>
            <span class="g2-legend-text" style="color: #666">${value}</span>
          </td>
        </tr>`;
      },
      tooltip: [
        "item*percent*count",
        (item, percent, count) => {
          //这里可以对数据进行处理
          percent = (percent * 100).toFixed(2) + "%";
          return {
            name: item,
            value: ["总数:" + count, "占比:" + percent].join(", "),
          };
        },
      ],
    };
  },
  props: ["sourceData"],
  watch: {
    sourceData: {
      deep: true,
      handler(nVal) {
        this.dv = new DataSet.View().source(nVal);
        this.dv.transform({
          type: "percent",
          field: "count",
          dimension: "item",
          as: "percent",
        });
        this.data = this.dv.rows;
      },
    },
  },
};
</script>

<style lang="less" scoped>
.g2-legend-list-item {
  display: block !important;
  margin: 5px 0 !important;
}
/deep/ .g2-legend-list-item {
  min-width: 40% !important;
}
/deep/ .zkdefine {
  text-align: left !important;
  margin-left: 100px !important;
}
</style>
