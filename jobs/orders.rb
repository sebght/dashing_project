require 'json'

dateFormatKey = '%Y-%m-%d'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    file = File.read('data/list-orders.json')
    jsonData = JSON.parse(file)

    fromDate = Date.parse(jsonData['from'])
    toDate = Date.parse(jsonData['to'])

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    today = toDate
    yesterday = toDate.prev_day(1)

    todayLabel = today.strftime("%A").to_s
    yesterdayLabel = yesterday.strftime("%A").to_s

    # Create hash with date as key
    orderListByDate = Hash.new

    fromDate.upto(toDate) do |date|
        orderListByDate[date.strftime(dateFormatKey)] = Hash.new
        orderListByDate[date.strftime(dateFormatKey)][:nbOrders] = 0
        orderListByDate[date.strftime(dateFormatKey)][:nbDays] = 0
        orderListByDate[date.strftime(dateFormatKey)][:avgNbOfOrders] = 0
        orderListByDate[date.strftime(dateFormatKey)][:points] = []
    end

    # Parse json data to fill orderListByDate hash
    jsonData['data'].each do |value|
        date = Date.parse("#{value['_id']['year']}-#{value['_id']['month']}-#{value['_id']['day']}")

        if !orderListByDate.has_key? date.strftime(dateFormatKey).to_s
            puts("orderListByDate has no key for date #{date}")
            next
        end

        orderListByDate[date.strftime(dateFormatKey)][:nbOrders] += value['nbOrders'].to_i
    end

    # Fill data for same day
    orderListByDate.each_pair do |key, value|
        date = Time.parse(key);

        # Ignore today data
        if date.strftime(dateFormatKey) == today.strftime(dateFormatKey)
            next
        end

        if date.strftime('%u') == today.strftime('%u')
            orderListByDate[today.strftime(dateFormatKey)][:nbDays] += 1
            orderListByDate[today.strftime(dateFormatKey)][:avgNbOfOrders] += value[:nbOrders]
            orderListByDate[today.strftime(dateFormatKey)][:points] << { x: date.to_time.to_i, y: value[:nbOrders] }
        end
    end

    # Fill data for yesterday day
    orderListByDate.each_pair do |key, value|
        date = Date.parse(key);

        if date.strftime('%u') == yesterday.strftime('%u')
            orderListByDate[yesterday.strftime(dateFormatKey)][:nbDays] += 1
            orderListByDate[yesterday.strftime(dateFormatKey)][:avgNbOfOrders] += value[:nbOrders]
            orderListByDate[yesterday.strftime(dateFormatKey)][:points] << { x: date.to_time.to_i, y: value[:nbOrders] }
        end
    end

    ordersPoints = []

    orderListByDate.each_pair do |key, value|
        date = Date.parse(key);

        if date.strftime(dateFormatKey) == today.strftime(dateFormatKey)
            next
        end

        ordersPoints << { x: date.to_time.to_i, y: value[:nbOrders] }
    end

    # Calculate avg for today
    nbOfDaysForToday = orderListByDate[today.strftime(dateFormatKey)][:nbDays]
    nbOfAvgOrdersForToday = (orderListByDate[today.strftime(dateFormatKey)][:avgNbOfOrders] / nbOfDaysForToday).floor

    # Calculate avg for yesterday
    nbOfDaysForYesterday = orderListByDate[yesterday.strftime(dateFormatKey)][:nbDays]
    nbOfAvgOrdersForYesterday = (orderListByDate[yesterday.strftime(dateFormatKey)][:avgNbOfOrders] / nbOfDaysForYesterday).floor

    send_event(
        "today_orders",
        {
            points: orderListByDate[today.strftime(dateFormatKey)][:points],
            current: orderListByDate[today.strftime(dateFormatKey)][:nbOrders],
            last: nbOfAvgOrdersForToday.to_i,
            moreinfo: "Avg on the #{nbOfDaysForToday} last #{todayLabel}s",
            title: "Paid orders<br/>Today",
            updatedAt: updatedAt
        }
    )

    send_event(
        "yesterday_orders",
        {
            points: orderListByDate[yesterday.strftime(dateFormatKey)][:points],
            current: orderListByDate[yesterday.strftime(dateFormatKey)][:nbOrders],
            last: nbOfAvgOrdersForYesterday,
            moreinfo: "Avg on the #{nbOfDaysForYesterday} last #{yesterdayLabel}s",
            title: "Paid orders<br/>Yesterday",
            updatedAt: updatedAt
        }
    )

    send_event(
        "avg_orders",
        {
            points: ordersPoints.pop(14),
            displayedValue: nbOfAvgOrdersForToday,
            title: "Avg nb of paid orders during the #{nbOfDaysForToday} last #{todayLabel}s",
            updatedAt: updatedAt
        }
    )
end
