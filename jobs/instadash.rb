require 'sinatra'
require 'instagram'

Instagram.configure do |config|
    config.client_id = '06f58ef28f8042fbb869f3634d8e748b'
    config.client_secret = '8293d8e604614fa58a18dcc1577bde40'
    config.access_token = '7669281.06f58ef.2cfaee4f653f4df599e5d49540bd5df9'
end

# This needs the user ID you want to display images of. Find out the ID for a username here: http://jelled.com/instagram/lookup-user-id
user_id = '2058637358'

# Uncomment the following line if you want to see the received output in your terminal (for debugging)
# puts Instagram.user_recent_media("#{user_id}")

SCHEDULER.every '60m', :first_in => 20 do |job|
    photos = Instagram.user_recent_media("#{user_id}")

    if photos
        photos.map! do |photo|
            { photo: "#{photo.images.low_resolution.url}" }
        end
    end

    send_event('instadash', photos: photos)
end