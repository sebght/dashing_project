require 'json'
require 'chronic'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    jsonData = JSON.parse(File.read('data/products-selection_fonct.json'))

    # Calculate nb of days last X days
    fromDate = Date.parse(jsonData['from'])
    toDate = Date.parse(jsonData['to'])

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    yesterday = toDate.prev_day(1)
    yesterdayRejected = 0
    todayRejected = 0
    yesterdayAwaiting = 0
    todayAwaiting = 0
    yesterdayPendingexp = 0
    todayPendingexp = 0
    todayPendingexpAccepted = 0
    yesterdayPendingexpAccepted = 0

    # Parse json data to fill orderListByDate hash
    jsonData['rejectedProducts'].each do |value|
        date = Date.parse(value['date']).to_date

        if date.strftime('%Y-%m-%d') == toDate.strftime('%Y-%m-%d')
            todayRejected = value['count']
        end

        if date.strftime('%Y-%m-%d') == yesterday.strftime('%Y-%m-%d')
            yesterdayRejected = value['count']
        end
        
    end
    
    jsonData['awaitingchangesProducts'].each do |value|
        date = Date.parse(value['date']).to_date
        
        if date.strftime('%Y-%m-%d') == toDate.strftime('%Y-%m-%d')
            todayAwaiting = value['count']
        end

        if date.strftime('%Y-%m-%d') == yesterday.strftime('%Y-%m-%d')
            yesterdayAwaiting = value['count']
        end
    end
    
    jsonData['pendingexpProducts'].each do |value|
        date = Date.parse(value['date']).to_date
        
        if date.strftime('%Y-%m-%d') == toDate.strftime('%Y-%m-%d')
            todayPendingexp = value['count']
        end

        if date.strftime('%Y-%m-%d') == yesterday.strftime('%Y-%m-%d')
            yesterdayPendingexp = value['count']
        end

    end
    
    jsonData['pendingExpAccepted'].each do |value|
        date = Date.parse(value['date']).to_date
        
        if date.strftime('%Y-%m-%d') == toDate.strftime('%Y-%m-%d')
            todayPendingexpAccepted = value['count']
        end

        if date.strftime('%Y-%m-%d') == yesterday.strftime('%Y-%m-%d')
            yesterdayPendingexpAccepted = value['count']
        end

    end

    send_event(
        "today_rejected_products",
        {
            current: todayRejected.round,
            last: yesterdayRejected.round,
            title: "Rejetés<br/>Aujourd'hui",
            moreinfo: "Nb produits rejetés hier: #{yesterdayRejected.round}",
            updatedAt: updatedAt
        }
    )
    
    send_event(
        "today_awaiting_products",
        {
            current: todayAwaiting.round,
            last: yesterdayAwaiting.round,
            title: "Envoyés en Modifs<br/>Aujourd'hui",
            moreinfo: "Nb produits envoyés en modif hier: #{yesterdayAwaiting.round}",
            updatedAt: updatedAt
        }
    )
    
    send_event(
        "today_pendingexp_products",
        {
            current: todayPendingexp.round,
            last: yesterdayPendingexp.round,
            title: "Envoyés à l'expertise<br/>Aujourd'hui",
            moreinfo: "Nb envoyés à l'expertise hier: #{yesterdayPendingexp.round}",
            updatedAt: updatedAt
        }
    )
    
    send_event(
        "new_pinned_products_now",
        {
            current: jsonData['newpinnedProducts'][0]['count'],
            updatedAt: updatedAt
        }
    )
    
    send_event(
        "pendingExpAccepted",
        {
            current: todayPendingexpAccepted.round,
            last: yesterdayPendingexpAccepted.round,
            title: "Authentifiés<br/>Aujourd'hui",
            moreinfo: "Nb produits authentifiés aujourd'hui: #{yesterdayPendingexpAccepted.round}",
            updatedAt: updatedAt
        }
    )
    
    counts = Hash.new
    jsonData['statusProducts'].each do |e|
        counts[e['_id']] = e['count']
    end
    
    send_event(
        "pending_review_now",
        {
            current: counts['pending_review'],
            updatedAt: updatedAt
        }
    )
    
    send_event(
        "awaiting_crop_now",
        {
            current: counts['awaiting_crop'],
            updatedAt: updatedAt
        }
    )
    
    send_event(
        "last_published_picture",
        {
            current: jsonData['lastmediaId'][0]['assetsmedia'],
            updatedAt: updatedAt
        }
    )
    
    
end
