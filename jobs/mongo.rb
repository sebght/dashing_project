require 'mongo'

MEGABYTE = 1024.0 * 1024.0

SCHEDULER.every('5m', first_in: '1s') {
    infoPrimary = JSON.parse(File.read('data/server-status-primary.json'))
    infoSecondary = JSON.parse(File.read('data/server-status-secondary.json'))

    send_event('mongo_connected_clients_primary', {
        max: infoPrimary['connections']['available'].to_i,
        value: infoPrimary['connections']['current'].to_i,
        moreinfo: "Connected clients"
    })

    send_event('mongo_connected_clients_secondary', {
        max: infoSecondary['connections']['available'].to_i,
        value: infoSecondary['connections']['current'].to_i,
        moreinfo: "Connected clients"
    })

    # Convert network in/out in bytes to MB
    network_in = infoPrimary['network']['bytesIn']['floatApprox'].to_i / MEGABYTE
    network_out = infoPrimary['network']['bytesOut']['floatApprox'].to_i / MEGABYTE

    send_event('mongo_network_info_primary', {
        network_requests: infoPrimary['network']['numRequests']['floatApprox'].to_i,
        network_in: network_in,
        network_out: network_out,
        moreinfo: "Network traffic info"
    })

    network_in = infoSecondary['network']['bytesIn']['floatApprox'].to_i / MEGABYTE
    network_out = infoSecondary['network']['bytesOut']['floatApprox'].to_i / MEGABYTE

    send_event('mongo_network_info_secondary', {
        network_requests: infoSecondary['network']['numRequests']['floatApprox'].to_i,
        network_in: network_in,
        network_out: network_out,
        moreinfo: "Network traffic info"
    })
}