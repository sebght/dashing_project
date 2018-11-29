require 'google/apis/analytics_v3'
require 'googleauth'
require 'googleauth/service_account'
require 'date'
require 'yaml'
require 'openssl'

# Fix ssl cert validation error
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

profile_id = "86655878"
scopes =  ['https://www.googleapis.com/auth/analytics.readonly']
authorization = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open('lib/dashing-8db77eb941b5.json'),
    scope: scopes
)

client = Google::Apis::AnalyticsV3::AnalyticsService.new

# Start the scheduler
SCHEDULER.every '30m', :first_in => 0 do
  client.authorization = authorization

  # Execute the query
  response =
      client.get_ga_data(
        "ga:" + profile_id,
        (DateTime.now - 7).strftime('%Y-%m-%d'),
        (DateTime.now - 1).strftime('%Y-%m-%d'),
        "ga:visitors"
      )

  currentWeekVisitors = 0
  lastWeekVisitors = 0

  # deals with no visits
  if response.rows[0] and response.rows[0][0]
    currentWeekVisitors = response.rows[0][0].to_i
  end

  # Execute the query
  response =
      client.get_ga_data(
          "ga:" + profile_id,
          (DateTime.now - 14).strftime('%Y-%m-%d'),
          (DateTime.now - 8).strftime('%Y-%m-%d'),
          "ga:visitors"
      )

  # deals with no visits
  if response.rows[0] and response.rows[0][0]
    lastWeekVisitors = response.rows[0][0].to_i
  end

  # Send data to view
  send_event("week_visitors", current: currentWeekVisitors, last: lastWeekVisitors) #, status: status)
end