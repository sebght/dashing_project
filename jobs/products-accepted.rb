require 'json'
require 'chronic'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    jsonData = JSON.parse(File.read('data/list-products-accepted.json'))

    # Calculate nb of days last X days
    fromDate = Date.parse(jsonData['from'])
    toDate = Date.parse(jsonData['to'])

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    yesterday = toDate.prev_day(1)
    yesterdayAccepted = 0
    todayAccepted = 0

    weekData = Hash.new
    weekData[:count] = 0
    weekData[:from] = Chronic.parse('last saturday').to_date
    weekData[:to] = weekData[:from].next_day(6)

    lastWeekData = Hash.new
    lastWeekData[:count] = 0
    lastWeekData[:from] = weekData[:from].prev_day(7)
    lastWeekData[:to] = weekData[:to].prev_day(7)

    monthData = Hash.new
    monthData[:from] = Date.new(toDate.strftime('%Y').to_i, toDate.strftime('%m').to_i, 1)
    monthData[:count] = 0
    monthData[:month] = monthData[:from].strftime('%m').to_i
    monthData[:year] = monthData[:from].strftime('%Y').to_i

    lastMonthData = Hash.new
    lastMonthData[:from] = Chronic.parse('1st day last month') # Date.new(toDate.strftime('%Y').to_i, toDate.strftime('%m').to_i - 1, 1)
    lastMonthData[:count] = 0
    lastMonthData[:month] = lastMonthData[:from].strftime('%m').to_i
    lastMonthData[:year] = lastMonthData[:from].strftime('%Y').to_i

    # Parse json data to fill orderListByDate hash
    jsonData['data'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.strftime('%Y-%m-%d') == toDate.strftime('%Y-%m-%d')
            todayAccepted = value['count']
        end

        if date.strftime('%Y-%m-%d') == yesterday.strftime('%Y-%m-%d')
            yesterdayAccepted = value['count']
        end

        if date.between?(weekData[:from], weekData[:to])
            weekData[:count] = weekData[:count] + value['count']
        end

        if date.between?(lastWeekData[:from], lastWeekData[:to])
            lastWeekData[:count] = lastWeekData[:count] + value['count']
        end

        if date.strftime('%Y').to_i == monthData[:year] && date.strftime('%-m').to_i == monthData[:month]
            monthData[:count] = monthData[:count] + value['count']
        end

        if date.strftime('%Y').to_i == lastMonthData[:year] && date.strftime('%-m').to_i == lastMonthData[:month]
            lastMonthData[:count] = lastMonthData[:count] + value['count']
        end
    end

    send_event(
        "today_accepted_products",
        {
            current: todayAccepted,
            last: yesterdayAccepted,
            title: "Accepted Products<br/>Today",
            moreinfo: "Nb accepted products yesterday: #{yesterdayAccepted}",
            updatedAt: updatedAt
        }
    )

    send_event(
        "week_accepted_products",
        {
            current: weekData[:count],
            last: lastWeekData[:count],
            title: "Accepted Products<br/>#{weekData[:from].strftime('%d %b.')} to #{weekData[:to].strftime('%d %b.')}",
            moreinfo: "Nb accepted during last period: #{lastWeekData[:count]}",
            updatedAt: updatedAt
        }
    )

    send_event(
        "month_accepted_products",
        {
            current: monthData[:count],
            last: lastMonthData[:count],
            title: "Accepted Products<br/>#{monthData[:from].strftime('%b. %Y')}",
            moreinfo: "#{lastMonthData[:from].strftime('%b. %Y')}: #{lastMonthData[:count]}",
            updatedAt: updatedAt
        }
    )
end
