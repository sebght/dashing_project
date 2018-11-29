require 'json'

dateFormatKey = '%Y-%m-%d'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    jsonOrdersData = JSON.parse(File.read('data/list-orders.json'))
    jsonOrderProductsData = JSON.parse(File.read('data/list-order-products.json'))

    fromDate = Date.parse(jsonOrdersData['from'])
    toDate = Date.parse(jsonOrdersData['to'])
    updatedAt = DateTime.parse(jsonOrdersData['update']).to_time.to_i

    today = toDate
    yesterday = toDate.prev_day(1)
    todayLabel = today.strftime("%A").to_s
    yesterdayLabel = yesterday.strftime("%A").to_s

    # Create hash with date as key
    data = Hash.new

    fromDate.upto(toDate) do |date|
        data[date.strftime(dateFormatKey)] = Hash.new
        data[date.strftime(dateFormatKey)][:nbOrders] = 0
        data[date.strftime(dateFormatKey)][:nbDays] = 0
        data[date.strftime(dateFormatKey)][:aov] = 0
        data[date.strftime(dateFormatKey)][:avgAov] = 0
        data[date.strftime(dateFormatKey)][:points] = []
    end

    # Parse json data to fill orderListByDate hash
    jsonOrdersData['data'].each do |value|
        #date = Date.parse(value['date']);
        date = Date.parse("#{value['_id']['year']}-#{value['_id']['month']}-#{value['_id']['day']}")

        if !data.has_key? date.strftime(dateFormatKey).to_s
            next
        end

        data[date.strftime(dateFormatKey)][:nbOrders] += value['nbOrders'].to_i
    end

    # Parse json data to fill orderListByDate hash
    jsonOrderProductsData['data'].each do |value|
        date = Date.parse(value['date']);
        #date = Date.parse("#{value['_id']['year']}-#{value['_id']['month']}-#{value['_id']['day']}")

        if !data.has_key? date.strftime(dateFormatKey).to_s
            next
        end

        data[date.strftime(dateFormatKey)][:aov] = (value['total'] / data[date.strftime(dateFormatKey)][:nbOrders]).floor
    end

    #puts("-1-#{data[today.strftime(dateFormatKey)][:aov]}")

    # Fill data for same day
    data.each_pair do |key, value|
        date = Date.parse(key);

        # Ignore today data
        if date.strftime(dateFormatKey) == today.strftime(dateFormatKey)
            next
        end

        if date.strftime('%u') == today.strftime('%u')
            data[today.strftime(dateFormatKey)][:nbDays] += 1
            data[today.strftime(dateFormatKey)][:avgAov] += value[:aov]
            data[today.strftime(dateFormatKey)][:points] << { x: date.to_time.to_i, y: value[:aov] }
        end
    end

    #puts("-2-#{data[today.strftime(dateFormatKey)][:aov]}")

    # Fill data for yesterday day
    data.each_pair do |key, value|
        date = Date.parse(key);

        if date.strftime('%u') == yesterday.strftime('%u')
            data[yesterday.strftime(dateFormatKey)][:nbDays] += 1
            data[yesterday.strftime(dateFormatKey)][:avgAov] += value[:aov]
            data[yesterday.strftime(dateFormatKey)][:points] << { x: date.to_time.to_i, y: value[:aov] }
        end
    end

    #puts("-3-#{data[today.strftime(dateFormatKey)][:aov]}")

    points = []

    data.each_pair do |key, value|
        date = Date.parse(key);

        if date.strftime(dateFormatKey) == today.strftime(dateFormatKey)
            next
        end

        points << { x: date.to_time.to_i, y: value[:aov] }
    end

    # Calculate avg for today
    nbOfDaysForToday = data[today.strftime(dateFormatKey)][:nbDays]
    nbOfAvgAovForToday = (data[today.strftime(dateFormatKey)][:avgAov] / nbOfDaysForToday).floor

    # Calculate avg for yesterday
    nbOfDaysForYesterday = data[yesterday.strftime(dateFormatKey)][:nbDays]
    nbOfAvgAovForYesterday = (data[yesterday.strftime(dateFormatKey)][:avgAov] / nbOfDaysForYesterday).floor

    #puts("-4-#{data[today.strftime(dateFormatKey)][:aov]}")

    send_event(
        "today_aov",
        {
            points: data[today.strftime(dateFormatKey)][:points],
            current: data[today.strftime(dateFormatKey)][:aov],
            last: nbOfAvgAovForToday.to_i,
            moreinfo: "Avg on the #{nbOfDaysForToday} last #{todayLabel}s",
            title: "AOV<br/>Today",
            updatedAt: updatedAt
        }
    )

    send_event(
        "yesterday_aov",
        {
            points: data[yesterday.strftime(dateFormatKey)][:points],
            current: data[yesterday.strftime(dateFormatKey)][:aov],
            last: nbOfAvgAovForYesterday,
            moreinfo: "Avg on the #{nbOfDaysForYesterday} last #{yesterdayLabel}s",
            title: "AOV<br/>Yesterday",
            updatedAt: updatedAt
        }
    )

    send_event(
        "avg_aov",
        {
            points: points.pop(14),
            displayedValue: nbOfAvgAovForToday,
            title: "Avg AOV during the #{nbOfDaysForToday} last #{todayLabel}s",
            updatedAt: updatedAt
        }
    )
end
