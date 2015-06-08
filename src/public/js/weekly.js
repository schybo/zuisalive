d3.json('/data/weekly.json', function(data) {
  nv.addGraph(function() {
    var chart = nv.models.stackedAreaChart()
                  .margin({right: 100})
                  .x(function(d) { return d[0] })   //We can modify the data accessor functions...
                  .y(function(d) { return d[1]*100 })   //...in case your data is formatted differently.
                  .useInteractiveGuideline(false)    //Tooltips which show all data points. Very nice!
                  .rightAlignYAxis(true)      //Let's move the y-axis to the right side.
                  // .transitionDuration(500)
                  .showControls(true)       //Allow user to choose 'Stacked', 'Stream', 'Expanded' mode.
                  .clipEdge(true);

    chart.xAxis
        .tickValues([1401595200000, 1404187200000, 1406865600000, 1409544000000, 1412136000000, 1414814400000, 1417410000000, 1420088400000, 1422766800000, 1425186000000, 1427860800000, 1430452800000, 1433131200000])
        .tickFormat(function(d) {
            return d3.time.format('%b-%Y')(new Date(d))
        });


    chart.yAxis
        .tickFormat(d3.format('$,f'));

    d3.select('#chart4 svg')
      .datum(data)
      .call(chart);

    nv.utils.windowResize(chart.update);

    return chart;
  });
})