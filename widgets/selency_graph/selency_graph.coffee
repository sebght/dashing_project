class Dashing.SelencyGraph extends Dashing.Widget

  @accessor 'current', ->
    return @get('displayedValue') if @get('displayedValue')
    points = @get('points')
    if points
      points[points.length - 1].y

  ready: ->
    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))
    @graph = new Rickshaw.Graph(
      element: @node
      width: width
      height: height
      renderer: @get("graphtype")
      series: [
        {
        color: "#fff",
        data: [{x:0, y:0}]
        }
      ]
      padding: {top: 0.02, left: 0.02, right: 0.02, bottom: 0.02}
    )

    @graph.series[0].data = @get('points') if @get('points')

    #x_axis = new Rickshaw.Graph.Axis.Time(graph: @graph)
    # x_axis = new Rickshaw.Graph.Axis.Time(
    #  graph: @graph,
    #  timeUnit:
    #    name: 'days'
    #    formatter: (d) -> d.getDay()
    #)

    timeFixture = new Rickshaw.Fixtures.Time();
    unitDay = timeFixture.unit('day');
    x_axis = new Rickshaw.Graph.Axis.Time(
      graph: @graph
      timeUnit: unitDay
      timeFixture: timeFixture
      formatter: (d) -> d.getMonth() + '/' + d.getDay()
    )

    #time = new Rickshaw.Fixtures.Time()
    #days = time.unit("day")

    #x_axis = new Rickshaw.Graph.Axis.Time(
    #  graph: @graph
    #  timeUnit: days
    #)

    y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickFormat: Rickshaw.Fixtures.Number.formatKMBT)
    @graph.render()

  onData: (data) ->
    if @graph
      @graph.series[0].data = data.points
      @graph.render()
