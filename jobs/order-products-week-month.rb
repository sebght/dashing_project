require 'json'
require 'chronic'

dateFormatKey = '%Y-%m-%d'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    jsonData = JSON.parse(File.read('data/list-order-products-month.json'))

    fromDate = Date.parse(jsonData['from'])
    toDate = Date.parse(jsonData['to'])

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    # Create hash with date as key
    orderProductListByDate = Hash.new

    weekData = Hash.new
    weekData[:number] = toDate.strftime('%W').to_i
    weekData[:total] = 0
    #weekData[:from] = Date.commercial(toDate.strftime('%Y').to_i, toDate.strftime('%W').to_i, 1)
    #weekData[:to] = Date.commercial(toDate.strftime('%Y').to_i, toDate.strftime('%W').to_i, 7)
    weekData[:from] = Chronic.parse('last saturday').to_date
    weekData[:to] = weekData[:from].next_day(6)

    lastWeekData = Hash.new
    lastWeekData[:number] = (toDate.to_time - 86400 * 7).strftime('%W').to_i
    lastWeekData[:total] = 0
    lastWeekData[:from] = weekData[:from].prev_day(7)
    lastWeekData[:to] = weekData[:to].prev_day(7)

    monthData = Hash.new
    monthData[:from] = Date.new(toDate.strftime('%Y').to_i, toDate.strftime('%m').to_i, 1)
    monthData[:total] = 0
    monthData[:month] = monthData[:from].strftime('%m').to_i
    monthData[:year] = monthData[:from].strftime('%Y').to_i

    lastMonthData = Hash.new
    lastMonthData[:from] = Chronic.parse('1st day last month') # Date.new(toDate.strftime('%Y').to_i, toDate.strftime('%-m').to_i - 1, 1)
    lastMonthData[:total] = 0
    lastMonthData[:month] = lastMonthData[:from].strftime('%m').to_i
    lastMonthData[:year] = lastMonthData[:from].strftime('%Y').to_i

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

        if date.between?(weekData[:from], weekData[:to])
            weekData[:total] = weekData[:total] + value['total']
        end

        if date.between?(lastWeekData[:from], lastWeekData[:to])
            lastWeekData[:total] = lastWeekData[:total] + value['total']
        end

        if date.strftime('%Y').to_i == monthData[:year] && date.strftime('%-m').to_i == monthData[:month]
            monthData[:total] = monthData[:total] + value['total']
        end

        if date.strftime('%Y').to_i == lastMonthData[:year] && date.strftime('%-m').to_i == lastMonthData[:month]
            lastMonthData[:total] = lastMonthData[:total] + value['total']
        end

        if !orderProductListByDate.has_key? date.strftime(dateFormatKey).to_s
            puts("orderListByDate has no key for date #{date}")
            next
        end

        orderProductListByDate[date.strftime(dateFormatKey)][:total] = value['total']
    end

    send_event(
        "week_gmv",
        {
            current: weekData[:total],
            last: lastWeekData[:total],
            title: "GMV<br/>#{weekData[:from].strftime('%d %b.')} to #{weekData[:to].strftime('%d %b.')}",
            moreinfo: "#{weekData[:from].strftime('%d/%m/%Y')} to #{weekData[:to].strftime('%d/%m/%Y')}",
            moreinfo: "#{lastWeekData[:from].strftime('%d/%m/%Y')} to #{lastWeekData[:to].strftime('%d/%m/%Y')}: #{lastWeekData[:total].floor} EUR",
            updatedAt: updatedAt
        }
    )

    send_event(
        "month_gmv",
        {
            current: monthData[:total],
            last: lastMonthData[:total],
            title: "GMV<br/>#{monthData[:from].strftime('%b. %Y')}",
            moreinfo: "#{lastMonthData[:from].strftime('%b. %Y')}: #{lastMonthData[:total].floor} EUR",
            updatedAt: updatedAt
        }
    )
end
