d3.json('/data/repeat.json', function(data) {
  nv.addGraph(function() {
    var chart = nv.models.multiBarChart()
      .x(function(d) { return d[0] })
      .y(function(d) { return d[1] }) //Keeping values low, 1.0 = 100
      .reduceXTicks(true)   //If 'false', every single x-axis tick label will be rendered.
      .rotateLabels(0)      //Angle to rotate x-axis labels.
      .showControls(true)   //Allow user to switch between 'Grouped' and 'Stacked' mode.
      .groupSpacing(0.1)    //Distance between each group of bars.
    ;

    chart.xAxis
        .tickValues([1401595200000, 1404187200000, 1406865600000, 1409544000000, 1412136000000, 1414814400000, 1417410000000, 1420088400000, 1422766800000, 1425186000000, 1427860800000, 1430452800000, 1433131200000])
        .tickFormat(function(d) {
            return d3.time.format('%b-%Y')(new Date(d))
          });

    chart.yAxis
        .tickFormat(d3.format('.1f'));

    d3.select('#chart3 svg')
        .datum(data)
        .call(chart);

    nv.utils.windowResize(chart.update);

    return chart;
});
});
