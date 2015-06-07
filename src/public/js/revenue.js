d3.json('/data/revenue.json', function(data) {
  nv.addGraph(function() {
    var graph = nv.models.cumulativeLineChart()
                  .x(function(d) { return d[0] })
                  .y(function(d) { return d[1]/100 }) //adjusting, 100% is 1.00, not 100 as it is in the data
                  .color(d3.scale.category10().range())
                  .useInteractiveGuideline(true);

     graph.xAxis
        .tickValues([1078030800000,1122782400000,1167541200000,1251691200000])
        .tickFormat(function(d) {
            return d3.time.format('%x')(new Date(d))
          });

    graph.yAxis
        .tickFormat(d3.format(',.1%'));

    d3.select('#chart2 svg')
        .datum(data)
        .call(graph);

    //TODO: Figure out a good way to do this automatically
    nv.utils.windowResize(graph.update);

    return graph;
  });
});