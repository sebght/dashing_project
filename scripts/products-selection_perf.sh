#!/bin/sh

# Copy query to mongo server
scp /home/sshuser/custom-scripts/dashing/products-selection_perf.js sshuser@mongo-01b:/home/sshuser/tmp/products-selection_perf.js

# Execute query
ssh mongo-01b "mongo s_product_prod --quiet /home/sshuser/tmp/products-selection_perf.js" > /home/sshuser/custom-scripts/dashing/temp/products-selection_perf.json

# Copy file to dev-02 server
scp /home/sshuser/custom-scripts/dashing/temp/products-selection_perf.json sshuser@dev-02:/space/dashing/data/products-selection_perf.json
