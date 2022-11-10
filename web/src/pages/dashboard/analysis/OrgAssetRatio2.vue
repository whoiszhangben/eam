<template>
  <div>
    <v-chart
      :force-fit="forceFit"
      :height="height"
      :data="sourceData"
      :padding="padding"
    >
      <v-tooltip :show-title="tooltipShowFalse" />
      <v-legend :offset="legendOffset" position="bottom-center" />
      <v-facet
        type="rect"
        :fields="facetFields"
        :padding="facetPadding"
        :row-title="facetRowTitle"
        :col-title="facetColTitle"
        :views="facetViews"
      ></v-facet>
    </v-chart>
  </div>
</template>

<script>
const DataSet = require("@antv/data-set");
const { DataView } = DataSet;

const views = (view, facet) => {
  const data = facet.data;
  const dv = new DataView();
  dv.source(data).transform({
    type: "percent",
    field: "total",
    dimension: "title",
    as: "percent",
  });

  return {
    data: dv,
    scale: {
      dataKey: "percent",
      formatter: ".2%",
    },
    coord: {
      type: "theta",
      innerRadius: 0.65,
    },
    series: {
      quickType: "stackBar",
      position: "percent",
      color: "title",
      label: [
        "percent",
        {
          offset: 8,
        },
      ],
      style: {
        lineWidth: 1,
        stroke: "#fff",
      },
    },
  };
};

export default {
  data() {
    return {
      forceFit: true,
      height: 220,
      padding: 30,
      tooltipShowFalse: false,
      legendOffset: 0,

      facetViews: views,
      facetFields: ["type"],
      facetPadding: 5,
      facetRowTitle: null,
      facetColTitle: {
        offsetX: -200,
        offsetY: 0,
        style: {
          fontSize: 16,
          textAlign: "center",
          fill: "#999",
        },
      },
    };
  },
  props: ["sourceData"],
};
</script>
