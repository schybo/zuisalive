d3.json('/data/revenue.json', function(data) {
  nv.addGraph(function() {
    var chart = nv.models.cumulativeLineChart()
                  .x(function(d) { return d[0] })
                  .y(function(d) { return d[1]*100 }) //Keeping values low, 1.0 = 100
                  .color(d3.scale.category10().range())
                  .useInteractiveGuideline(true)
                  ;

     chart.xAxis
        .tickValues([1401595200000, 1404187200000, 1406865600000, 1409544000000, 1412136000000, 1414814400000, 1417410000000, 1420088400000, 1422766800000, 1425186000000, 1427860800000, 1430452800000, 1433131200000])
        .tickFormat(function(d) {
            return d3.time.format('%b-%Y')(new Date(d))
          });

    chart.yAxis
        .tickFormat(d3.format('$,f'));

    d3.select('#chart2 svg')
        .datum(data)
        .call(chart);

    //TODO: Figure out a good way to do this automatically
    nv.utils.windowResize(chart.update);

    return chart;
  });
});