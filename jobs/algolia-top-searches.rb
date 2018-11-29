require 'date'
require 'net/http'
require 'uri'
require 'json'
require 'chronic'

searchApiKey = "58c9f55c46539ba2f88f346b958b4fd2"
applicationId = "V4R97D30NY"

# Start the scheduler
SCHEDULER.every '10m', :first_in => 0 do
    now = DateTime.now

    startAt = DateTime.new(now.year, now.month, now.day - 1, 0, 0, 1, now.zone)
    endAt = DateTime.new(now.year, now.month, now.day, 23, 59, 59, now.zone)

    uri = URI.parse("https://analytics.algolia.com/1/searches/catalog_product/popular?startAt=#{startAt.to_time.to_i}&endAt=#{endAt.to_time.to_i}&size=5")

    request = Net::HTTP::Get.new(uri)
    request["X-Algolia-Application-Id"] = applicationId
    request["X-Algolia-API-Key"] = searchApiKey
    req_options = { use_ssl: uri.scheme == "https" }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
    end

    data = JSON.parse(response.body)
    items = []

    data["topSearches"].each do |value|
        items << { label: value["query"], value: value["count"]}
    end

    send_event(
        "algolia_popular_searches",
        title: "Popular searches",
        items: items,
        moreinfo: "From #{startAt.strftime('%d/%m/%Y')}"
    )
end