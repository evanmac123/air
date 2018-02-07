var Airbo = window.Airbo || {};

Airbo.ClientAdminReportsDashboardSubmodules = (function() {
  var $parentModule;

  function buildSubmodule($submodule, $module) {
    $parentModule = $module;
    prepNewSubmodule($submodule);

    $.ajax({
      url: $submodule.data("path"),
      type: "GET",
      data: submoduleStrongParams($submodule),
      dataType: "json",
      success: function(response, status, xhr) {
        var reportData = response.data.attributes;

        buildSubmoduleGraphs(reportData, $submodule);
        displaySubmodule($submodule);
      },
      fail: function(response, status, xhr) {}
    });
  }

  function prepNewSubmodule($submodule) {
    $submodule.hide();
    $submodule.siblings(".card-header-content-loader").show();
    $submodule
      .find(".circle-progress-chart")
      .children("svg")
      .remove();
  }

  function submoduleStrongParams($submodule) {
    return {
      report_params: {
        report_type: $submodule.data("report"),
        from_date: $parentModule.data("startDate"),
        to_date: $parentModule.data("endDate"),
        demo_id: Airbo.ClientAdminReportsUtils.reportsBoardId()
      }
    };
  }

  function buildSubmoduleGraphs(reportData, $submodule) {
    var $dataGraphs = $submodule.find(".data-container");

    $.each($dataGraphs, function(i, graph) {
      buildSubmoduleGraph($(graph), reportData);
    });
  }

  function buildSubmoduleGraph($graph, reportData) {
    var dataPoint = getDecoratedDataPoint($graph, reportData);

    $graph.find(".num").text(dataPoint);

    if ($graph.data("showGraph")) {
      buildAndAnimateProgressGraph($graph);
    }
  }

  function displaySubmodule($submodule) {
    $submodule.siblings(".card-header-content-loader").hide();
    $submodule.show();
  }

  function buildAndAnimateProgressGraph($graph) {
    var progressGraph = new ProgressBar.Circle($graph.data("target"), {
      strokeWidth: 6,
      easing: "easeInOut",
      duration: 1400,
      color: $graph.data("graphColor"),
      trailColor: "#26374f",
      trailWidth: 6
    });

    progressGraph.animate($graph.data("graphFillPercent"));
  }

  function getDecoratedDataPoint($graph, reportData) {
    var dataAttribute = $graph.data("reportAttribute");
    var dataPoint = reportData[dataAttribute];

    if ($graph.find(".num").hasClass("percent")) {
      $graph.data("graphFillPercent", dataPoint);
      return decoratePercentDataPoint(dataPoint);
    } else {
      return decorateInteger(dataPoint);
    }
  }

  function decoratePercentDataPoint(dataPoint) {
    return Math.round(dataPoint * 100) + "%";
  }

  function decorateInteger(dataPoint) {
    if (dataPoint) {
      return dataPoint.toLocaleString("en-US");
    }
  }

  return {
    buildSubmodule: buildSubmodule
  };
})();
