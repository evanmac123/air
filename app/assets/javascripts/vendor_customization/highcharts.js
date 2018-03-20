Highcharts.dateFormats = {
  Q: function(timestamp) {
    var s = "",
      d = new Date(moment(timestamp).add("1", "day")),
      q = Math.floor((d.getMonth() + 3) / 3); //get quarter
    s = "Q" + q + " " + d.getFullYear();
    return s;
  }
};

Highcharts.setOptions({
  colors: ["#48bfff", "#4fd4c0", "#ffb748", "#b6a9f1", "#33445c"],
  chart: {
    style: {
      fontFamily: "Avenir Next Airbo"
    }
  },
  plotOptions: {
    column: {
      maxPointWidth: 200
    }
  }
});
