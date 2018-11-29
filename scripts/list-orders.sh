#!/bin/sh

# Copy query to mongo server
scp /home/sshuser/custom-scripts/dashing/list-orders.js sshuser@mongo-01b:/home/sshuser/tmp/list-orders.js

# Execute query
ssh mongo-01b "mongo s_checkout_prod --quiet /home/sshuser/tmp/list-orders.js" > /home/sshuser/custom-scripts/dashing/temp/list-orders.json

# Copy file to dev-02 server
scp /home/sshuser/custom-scripts/dashing/temp/list-orders.json sshuser@dev-02:/space/dashing/data/list-orders.json
