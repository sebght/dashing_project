#!/bin/sh

# Copy query to mongo server
scp /home/sshuser/custom-scripts/dashing/list-products-accepted.js sshuser@mongo-01b:/home/sshuser/tmp/list-products-accepted.js

# Execute query
ssh mongo-01b "mongo s_product_prod --quiet /home/sshuser/tmp/list-products-accepted.js" > /home/sshuser/custom-scripts/dashing/temp/list-products-accepted.json

# Copy file to dev-02 server
scp /home/sshuser/custom-scripts/dashing/temp/list-products-accepted.json sshuser@dev-02:/space/dashing/data/list-products-accepted.json
