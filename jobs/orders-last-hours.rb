require 'date'
require 'net/http'
require 'uri'
require 'json'

dateFormatKey = '%Y-%m-%d'
dateHourFormatKey = '%Y-%m-%d_%H'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    file = File.read('data/list-orders.json')
    jsonData = JSON.parse(file)

    fromDate = Date.parse(jsonData['from'])
    toDate = Date.parse(jsonData['to'])

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    today = toDate
    maxHour = DateTime.now.strftime('%H').to_i
    #maxHour = maxHour > 23 ? 23 : maxHour

    # Create hash with hour as key
    data = Hash.new

    0.upto(maxHour) do |hour|
        data[hour] = Hash.new
        data[hour][:nbTodayOrders] = 0
        data[hour][:nbPastOrders] = 0
        data[hour][:nbPastData] = 0
    end

    # Parse json data to fill orderList hash
    jsonData['data'].each do |value|
        if value['_id']['hour'] > maxHour
            next
        end

        dateTime =
            DateTime.new(
                value['_id']['year'].to_i,
                value['_id']['month'].to_i,
                value['_id']['day'].to_i,
                value['_id']['hour']
            )

        # Only check same day data
        if dateTime.strftime('%u') != today.strftime('%u')
            next
        end

        hour = value['_id']['hour'].to_i

        if dateTime.strftime(dateFormatKey) == today.strftime(dateFormatKey)
            data[hour][:nbTodayOrders] = value['nbOrders'].to_i
        else
            data[hour][:nbPastOrders] += value['nbOrders'].to_i
            data[hour][:nbPastData] += 1
        end
    end

    nbTotalOrders = 0

    # Calculate avg nb of orders for past data
    data.each_pair do |hour, value|
        nbTotalOrders += data[hour][:nbTodayOrders]

        if data[hour][:nbPastData] > 0
            data[hour][:nbPastOrders] = (data[hour][:nbPastOrders] / data[hour][:nbPastData]).to_f
        end
    end

    points = []
    pastPoints = []

    data.each_pair do |hour, value|
        points << {
            x: DateTime.new(today.strftime('%Y').to_i, today.strftime('%m').to_i, today.strftime('%d').to_i, hour, 30).to_time.to_i,
            y: data[hour][:nbTodayOrders]
        }

        pastPoints << {
            x: DateTime.new(today.strftime('%Y').to_i, today.strftime('%m').to_i, today.strftime('%d').to_i, hour, 30).to_time.to_i,
            y: data[hour][:nbPastOrders]
        }
    end

    send_event(
        "orders_realtime",
        {
            title: 'Today paid orders',
            displayedValue: nbTotalOrders,
            points: [ points, pastPoints ],
            pointNames: [ 'Today', 'Avg' ],
            updatedAt: updatedAt
        }
    )

    #puts(data)
end
