require 'json'

dateFormatKey = '%Y-%m-%d'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    jsonData = JSON.parse(File.read('data/list-order-products.json'))

    fromDate = Date.parse(jsonData['from'])
    toDate = Date.parse(jsonData['to'])

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    today = toDate
    yesterday = toDate.to_time - 86400

    todayLabel = today.strftime("%A").to_s
    yesterdayLabel = yesterday.strftime("%A").to_s

    # Create hash with date as key
    orderProductListByDate = Hash.new

    fromDate.upto(toDate) do |date|
        orderProductListByDate[date.strftime(dateFormatKey)] = Hash.new
        orderProductListByDate[date.strftime(dateFormatKey)][:total] = 0
        orderProductListByDate[date.strftime(dateFormatKey)][:avg] = 0
        orderProductListByDate[date.strftime(dateFormatKey)][:nbDays] = 0
        orderProductListByDate[date.strftime(dateFormatKey)][:points] = []
    end

    # Parse json data to fill orderListByDate hash
    jsonData['data'].each do |value|
        date = Date.parse(value['date']);

        if !orderProductListByDate.has_key? date.strftime(dateFormatKey).to_s
            puts("orderListByDate has no key for date #{date}")
            next
        end

        orderProductListByDate[date.strftime(dateFormatKey)][:total] = value['total']
    end

    # Fill data for same day
    orderProductListByDate.each_pair do |key, value|
        date = Date.parse(key);

        # Ignore today data
        if date.strftime(dateFormatKey) == today.strftime(dateFormatKey)
            next
        end

        if date.strftime('%u') == today.strftime('%u')
            orderProductListByDate[today.strftime(dateFormatKey)][:nbDays] += 1
            orderProductListByDate[today.strftime(dateFormatKey)][:avg] += value[:total]
            orderProductListByDate[today.strftime(dateFormatKey)][:points] << { x: date.to_time.to_i, y: value[:total] }
        end
    end

    # Fill data for yesterday day
    orderProductListByDate.each_pair do |key, value|
        date = Date.parse(key);

        if date.strftime('%u') == yesterday.strftime('%u')
            orderProductListByDate[yesterday.strftime(dateFormatKey)][:nbDays] += 1
            orderProductListByDate[yesterday.strftime(dateFormatKey)][:avg] += value[:total]
            orderProductListByDate[yesterday.strftime(dateFormatKey)][:points] << { x: date.to_time.to_i, y: value[:total].to_i }
        end
    end

    points = []

    orderProductListByDate.each_pair do |key, value|
        date = Date.parse(key);

        if date.strftime(dateFormatKey) == today.strftime(dateFormatKey)
            next
        end

        points << { x: date.to_time.to_i, y: value[:total].to_i }
    end

    # Calculate avg for today
    nbOfDaysForToday = orderProductListByDate[today.strftime(dateFormatKey).to_s][:nbDays]
    avgPriceForToday = (orderProductListByDate[today.strftime(dateFormatKey).to_s][:avg] / nbOfDaysForToday).floor

    # Calculate avg for yesterday
    nbOfDaysForYesterday = orderProductListByDate[yesterday.strftime(dateFormatKey).to_s][:nbDays]
    avgPriceForYesterday = (orderProductListByDate[yesterday.strftime(dateFormatKey).to_s][:avg] / nbOfDaysForYesterday).floor

    send_event(
        "today_gmv",
        {
            points: orderProductListByDate[today.strftime(dateFormatKey).to_s][:points],
            current: orderProductListByDate[today.strftime(dateFormatKey).to_s][:total].to_i,
            last: avgPriceForToday.to_i,
            moreinfo: "Avg on the #{nbOfDaysForToday} last #{todayLabel}s",
            title: "GMV<br/>Today",
            updatedAt: updatedAt
        }
    )

    send_event(
        "yesterday_gmv",
        {
            points: orderProductListByDate[yesterday.strftime(dateFormatKey).to_s][:points],
            current: orderProductListByDate[yesterday.strftime(dateFormatKey).to_s][:total].to_i,
            last: avgPriceForYesterday.to_i,
            moreinfo: "Avg on the #{nbOfDaysForYesterday} last #{yesterdayLabel}s",
            title: "GMV<br/>Yesterday",
            updatedAt: updatedAt
        }
    )

    send_event(
        "avg_gmv",
        {
            points: points.pop(14),
            displayedValue: avgPriceForToday.to_i,
            title: "Avg gmv during the #{nbOfDaysForToday} last #{todayLabel}s",
            updatedAt: updatedAt
        }
    )
end
