# dashing.js is located in the dashing framework
# It includes jquery & batman for you.
#= require dashing.js
#= require moment.js
#= require moment-timezone-with-data.js
#= require mobile-detect.min.js
#= require timeknots.js
#= require dashing-contrib/assets/widgets

#= require_directory .
#= require_tree ../../widgets

console.log("Yeah! The dashboard has started!")

Dashing.on 'ready', ->
  Dashing.debugMode = true
  Dashing.widget_margins ||= [5, 5]
  Dashing.widget_base_dimensions ||= [300, 360]
  Dashing.numColumns ||= 4

  contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns

  Batman.setImmediate ->
    $('.gridster').width(contentWidth)
    $('.gridster ul:first').gridster
      widget_margins: Dashing.widget_margins
      widget_base_dimensions: Dashing.widget_base_dimensions
      avoid_overlapped_widgets: !Dashing.customGridsterLayout
      draggable:
        stop: Dashing.showGridsterInstructions
        start: -> Dashing.currentWidgetPositions = Dashing.getWidgetPositions()

  #Batman.Filters.fixed = (num, f) ->
  #  return parseFloat(num).toFixed(f)

  Batman.Filters.shortenedNumber = (num) ->
    return num if isNaN(num)

    if num >= 1000000000
      (num / 1000000000).toFixed(1) + 'B'
    #else if num >= 1000000
    #  (num / 1000000).toFixed(6) + 'M'
    else if num >= 1000
      (num / 1000).toFixed(1) + 'K'
    else
      num