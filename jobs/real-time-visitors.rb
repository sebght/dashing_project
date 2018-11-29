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

maxDataLength = 20
visitors = []

# Start the scheduler
SCHEDULER.every '30s', :first_in => 0 do
  client.authorization = authorization

  # Execute the query
  response = client.get_realtime_data("ga:" + profile_id, "ga:activeVisitors")

  visitors << { x: Time.now.to_i, y: response.rows[0][0].to_i }

  # Limit number of data to show - remove first element
  if visitors.size > maxDataLength
      visitors.shift
  end

  # Update the dashboard
  send_event('real_time_visitors', points: visitors, displayValue: response.rows)
end