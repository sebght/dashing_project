#!/bin/sh

# Copy query to mongo server
scp /home/sshuser/custom-scripts/dashing/list-order-products-month.js sshuser@mongo-01b:/home/sshuser/tmp/list-order-products-month.js

# Execute query
ssh mongo-01b "mongo s_checkout_prod --quiet /home/sshuser/tmp/list-order-products-month.js" > /home/sshuser/custom-scripts/dashing/temp/list-order-products-month.json

# Copy file to dev-02 server
scp /home/sshuser/custom-scripts/dashing/temp/list-order-products-month.json sshuser@dev-02:/space/dashing/data/list-order-products-month.json
