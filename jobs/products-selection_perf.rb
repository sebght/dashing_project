require 'json'
require 'chronic'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    jsonData = JSON.parse(File.read('data/products-selection_perf.json'))

    # Calculate nb of days last X days
    fromDate = Date.parse(jsonData['from'])
    toDate = Date.parse(jsonData['to'])

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    yesterday = toDate.prev_day(1)
    yesterdayAwaitAccepted = 0
    todayAwaitAccepted = 0

    weekData = Hash.new
    weekData[:count] = 0
    weekData[:from] = Chronic.parse('last saturday').to_date
    weekData[:to] = weekData[:from].next_day(6)

    lastWeekData = Hash.new
    lastWeekData[:count] = 0
    lastWeekData[:from] = weekData[:from].prev_day(7)
    lastWeekData[:to] = weekData[:to].prev_day(7)

    # Awaiting Changes & Accepted this week
    jsonData['AWAcceptedProducts'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData[:from], weekData[:to])
            weekData[:count] = weekData[:count] + value['count']
        end

        if date.between?(lastWeekData[:from], lastWeekData[:to])
            lastWeekData[:count] = lastWeekData[:count] + value['count']
        end
    end

    send_event(
        "week_awaiting_accepted_products",
        {
            current: weekData[:count].round,
            last: lastWeekData[:count].round,
            title: "Modifiés & Acceptés<br/>#{weekData[:from].strftime('%d %b.')} to #{weekData[:to].strftime('%d %b.')}",
            moreinfo: "Nb modifiés & acceptés la semaine dernière: #{lastWeekData[:count].round}",
            updatedAt: updatedAt
        }
    )
    
    weekData[:count] = 0
    lastWeekData[:count] = 0
    
    # Pending Expertize & Accepted this week
    jsonData['DesignedAcceptedProducts'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData[:from], weekData[:to])
            weekData[:count] = weekData[:count] + value['count']
        end

        if date.between?(lastWeekData[:from], lastWeekData[:to])
            lastWeekData[:count] = lastWeekData[:count] + value['count']
        end
    end

    send_event(
        "week_designed_accepted_products",
        {
            current: weekData[:count].round,
            last: lastWeekData[:count].round,
            title: "Authentifiés<br/>du #{weekData[:from].strftime('%d %b.')} au #{weekData[:to].strftime('%d %b.')}",
            moreinfo: "Nb produits authentifiés la semaine dernière: #{lastWeekData[:count].round}",
            updatedAt: updatedAt
        }
    )
    
    weekData[:count] = 0
    lastWeekData[:count] = 0
    
    # Pinned Products this week
    jsonData['pinnedProducts'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData[:from], weekData[:to])
            weekData[:count] = weekData[:count] + value['count']
        end

        if date.between?(lastWeekData[:from], lastWeekData[:to])
            lastWeekData[:count] = lastWeekData[:count] + value['count']
        end
    end

    send_event(
        "week_pinned_products",
        {
            current: weekData[:count].round,
            last: lastWeekData[:count].round,
            title: "Pinnés<br/>du #{weekData[:from].strftime('%d %b.')} au #{weekData[:to].strftime('%d %b.')}",
            moreinfo: "Nb pinnés la semaine dernière: #{lastWeekData[:count].round}",
            updatedAt: updatedAt
        }
    )
    
    weekData[:count] = 0
    lastWeekData[:count] = 0
    
    # GMV Pinned Products this week
    jsonData['GMVpinnedProducts'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData[:from], weekData[:to])
            weekData[:count] = weekData[:count] + value['value']
        end

        if date.between?(lastWeekData[:from], lastWeekData[:to])
            lastWeekData[:count] = lastWeekData[:count] + value['value']
        end
    end

    send_event(
        "GMV_week_pinned_products",
        {
            current: weekData[:count],
            last: lastWeekData[:count],
            title: "GMV Produits Pinnés<br/>du #{weekData[:from].strftime('%d %b.')} au #{weekData[:to].strftime('%d %b.')}",
            moreinfo: "GMV pinnés semaine dernière: #{lastWeekData[:count]}",
            updatedAt: updatedAt
        }
    )
    
    weekData[:count] = 0
    lastWeekData[:count] = 0
    
    # Pending_review this week
    
    weekData2 = Hash.new
    weekData2[:count] = 0
    weekData2[:from] = Chronic.parse('last saturday').to_date
    weekData2[:to] = weekData2[:from].next_day(6)

    lastWeekData2 = Hash.new
    lastWeekData2[:count] = 0
    lastWeekData2[:from] = weekData2[:from].prev_day(7)
    lastWeekData2[:to] = weekData2[:to].prev_day(7)
    
    jsonData['pendingreviewResults'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData2[:from], weekData2[:to])
            weekData2[:count] = weekData2[:count] + value['count']
        end

        if date.between?(lastWeekData2[:from], lastWeekData2[:to])
            lastWeekData2[:count] = lastWeekData2[:count] + value['count']
        end
    end
    
    # Rejected Products this week
    
    weekData3 = Hash.new
    weekData3[:count] = 0
    weekData3[:from] = Chronic.parse('last saturday').to_date
    weekData3[:to] = weekData3[:from].next_day(6)

    lastWeekData3 = Hash.new
    lastWeekData3[:count] = 0
    lastWeekData3[:from] = weekData3[:from].prev_day(7)
    lastWeekData3[:to] = weekData3[:to].prev_day(7)
    
    jsonData['rejectedResults'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData3[:from], weekData3[:to])
            weekData3[:count] = weekData3[:count] + value['count']
        end

        if date.between?(lastWeekData3[:from], lastWeekData3[:to])
            lastWeekData3[:count] = lastWeekData3[:count] + value['count']
        end
    end

    send_event(
      "taux_rejet_this_week",
      current: 100*weekData3[:count]/weekData2[:count],
      last: 100*lastWeekData3[:count]/lastWeekData2[:count],
      moreinfo: "Durant cette semaine"
  )
    
    # Nb accepted this week
    
    weekData5 = Hash.new
    weekData5[:count] = 0
    weekData5[:from] = Chronic.parse('last saturday').to_date
    weekData5[:to] = weekData5[:from].next_day(6)

    lastWeekData5 = Hash.new
    lastWeekData5[:count] = 0
    lastWeekData5[:from] = weekData5[:from].prev_day(7)
    lastWeekData5[:to] = weekData5[:to].prev_day(7)
    
    jsonData['acceptedProducts'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData5[:from], weekData5[:to])
            weekData5[:count] = weekData5[:count] + value['count']
        end

        if date.between?(lastWeekData5[:from], lastWeekData5[:to])
            lastWeekData5[:count] = lastWeekData5[:count] + value['count']
        end
    end
    
    # Price accepted this week
    
    weekData4 = Hash.new
    weekData4[:count] = 0
    weekData4[:from] = Chronic.parse('last saturday').to_date
    weekData4[:to] = weekData4[:from].next_day(6)

    lastWeekData4 = Hash.new
    lastWeekData4[:count] = 0
    lastWeekData4[:from] = weekData4[:from].prev_day(7)
    lastWeekData4[:to] = weekData4[:to].prev_day(7)
    
    jsonData['acceptedProducts'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.between?(weekData4[:from], weekData4[:to])
            weekData4[:count] = weekData4[:count] + value['value']
        end

        if date.between?(lastWeekData4[:from], lastWeekData4[:to])
            lastWeekData4[:count] = lastWeekData4[:count] + value['value']
        end
    end

    send_event(
      "avg_price_accepted_this_week",
      current: (weekData4[:count]/weekData5[:count]).round,
      last: (lastWeekData4[:count]/lastWeekData5[:count]).round,
      title: "Prix moyen des Acceptés<br/>du #{weekData4[:from].strftime('%d %b.')} au #{weekData4[:to].strftime('%d %b.')}",
      moreinfo: "Prix moyen acceptés semaine dernière: #{(lastWeekData4[:count]/lastWeekData5[:count]).round}",
      updatedAt: updatedAt
  )
    
end
