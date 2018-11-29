#!/bin/sh

# Copy query to mongo server
scp /home/sshuser/custom-scripts/dashing/list-order-products.js sshuser@mongo-01b:/home/sshuser/tmp/list-order-products.js

# Execute query
ssh mongo-01b "mongo s_checkout_prod --quiet /home/sshuser/tmp/list-order-products.js" > /home/sshuser/custom-scripts/dashing/temp/list-order-products.json

# Copy file to dev-02 server
scp /home/sshuser/custom-scripts/dashing/temp/list-order-products.json sshuser@dev-02:/space/dashing/data/list-order-products.json
