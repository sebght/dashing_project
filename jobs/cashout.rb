require 'date'
require 'json'

dateFormatKey = '%Y-%m-%d'
dateHourFormatKey = '%Y-%m-%d_%H'

# Start the scheduler
SCHEDULER.every '1m', :first_in => 0 do
    file = File.read('data/cashout.json')
    jsonData = JSON.parse(file)

    updatedAt = DateTime.parse(jsonData['update']).to_time.to_i

    counts = Hash.new
    amounts = Hash.new
    jsonData['cashoutPayments'].each do |e|
        counts[e['_id']] = e['count']
        amounts[e['_id']] = e['value']
    end

    send_event(
        "cashout_payments_check_required",
        {
            current: counts['check_required'],
            updatedAt: updatedAt
        }
    )

    send_event(
        "cashout_payments_check_required_amount",
        {
            current: amounts['check_required'],
            updatedAt: updatedAt
        }
    )

    send_event(
        "cashout_payments_to_process",
        {
            current: counts['to_process'],
            updatedAt: updatedAt
        }
    )

    send_event(
        "cashout_payments_to_process_amount",
        {
            current: amounts['to_process'],
            updatedAt: updatedAt
        }
    )

    send_event(
        "cashout_payments_processed_today",
        {
            current: jsonData['cashoutPaymentsProcessedToday'][0]['count'],
            updatedAt: updatedAt
        }
    )

    send_event(
        "cashout_payments_processed_today_amount",
        {
            current: jsonData['cashoutPaymentsProcessedToday'][0]['value'],
            updatedAt: updatedAt
        }
    )

    send_event(
        "order_products_transfer_requested",
        {
            current: jsonData['orderProductsTransferRequested'][0]['count'],
            updatedAt: updatedAt
        }
    )
end
