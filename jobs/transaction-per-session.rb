require 'google/apis/analytics_v3'
require 'googleauth'
require 'googleauth/service_account'
require 'date'
require 'yaml'

profile_id = "86655878"
scopes =  ['https://www.googleapis.com/auth/analytics.readonly']
authorization = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open('lib/dashing-8db77eb941b5.json'),
    scope: scopes
)

client = Google::Apis::AnalyticsV3::AnalyticsService.new

# Start the scheduler
SCHEDULER.every '10m', :first_in => 0 do
  client.authorization = authorization

  # Execute the query
  response =
      client.get_ga_data(
        "ga:" + profile_id,
        (DateTime.now - 7).strftime('%Y-%m-%d'),
        (DateTime.now - 1).strftime('%Y-%m-%d'),
        "ga:transactionsPerSession"
      )

  currentWeekTxPerSession = 0
  lastWeekTxPerSession = 0

  # deals with no visits
  if response.rows
    currentWeekTxPerSession = response.rows
  end

  # Execute the query
  response =
      client.get_ga_data(
          "ga:" + profile_id,
          (DateTime.now - 14).strftime('%Y-%m-%d'),
          (DateTime.now - 8).strftime('%Y-%m-%d'),
          "ga:transactionsPerSession"
      )

  # deals with no visits
  if response.rows
    lastWeekTxPerSession = response.rows
  end

  # Execute the query
  response =
      client.get_ga_data(
          "ga:" + profile_id,
          DateTime.now.strftime('%Y-%m-%d'),
          (DateTime.now).strftime('%Y-%m-%d'),
          "ga:transactionsPerSession"
      )

  todayTxPerSession = 0

  # deals with no visits
  if response.rows
    todayTxPerSession = response.rows
  end

  # Send data to view
  send_event(
      "weekly_transaction_per_session",
      current: currentWeekTxPerSession,
      last: lastWeekTxPerSession,
      moreinfo: "During the last 7 days"
  )

  send_event(
      "today_transaction_per_session",
      current: todayTxPerSession,
      last: currentWeekTxPerSession
  ) #, status: status)
end