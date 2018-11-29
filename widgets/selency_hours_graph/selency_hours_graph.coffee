class Dashing.SelencyHoursGraph extends Dashing.Widget

  @accessor 'current', ->
    return @get('displayedValue') if @get('displayedValue')
    points = @get('points')
    if points
      points[0][points[0].length - 1].y + ' / ' + points[1][points[1].length - 1].y

  ready: ->
    container = $(@node).parent()

    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))

    @graph = new Rickshaw.Graph(
      element: @node
      width: width
      height: height
      renderer: 'area' #@get("graphtype")
      series: [
        {
          name: @get('pointNames')[0],
          color: '#70D0FF',
          data: @get('points')[0]
        },
        {
          name: @get('pointNames')[1],
          color: '#476677',
          data: @get('points')[1]
        }
      ]
      padding: {top: 0.02, left: 0.02, right: 0.02, bottom: 0.02}
    )

    timeFixture = new Rickshaw.Fixtures.Time();
    unitDay = timeFixture.unit('hour');
    x_axis = new Rickshaw.Graph.Axis.Time(
      graph: @graph
      timeUnit: unitDay
      timeFixture: timeFixture
      formatter: (d) -> d.getHours()

    )

    y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickFormat: Rickshaw.Fixtures.Number.formatKMBT)

    @$legendDiv = $("<div style='width: #{width}px;'></div>")
    #container.append(@$legendDiv)

    legend = new Rickshaw.Graph.Legend {
      graph: @graph
      element: @$legendDiv.get(0)
    }

    @graph.renderer.stroke = true
    @graph.render()

  onData: (data) ->
    if @graph
      @graph.series[0].data = data.points[0]
      @graph.series[1].data = data.points[1]
      @graph.render()
